import app/router
import app/web
import blog/posts
import filepath
import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam_community/ansi
import shellout
import simplifile
import tagg_config
import utils
import wisp
import wisp/testing

pub fn main() -> Nil {
  let do_res = {
    let res =
      simplifile.current_directory()
      |> result.map_error(fn(_) { "Failed to get current directory" })
    use pwd <- result.try(res)

    let build_html_result = {
      build_site(pwd)
      |> result.map(fn(_) { io.println("HTML built successfully") })
    }
    use _ <- result.try(build_html_result)

    let format_html = {
      // run html formatter
      use #(_ecode, msg) <- result.map_error(
        shellout.command(
          run: "prettier",
          with: ["--write", "**/*.html"],
          in: filepath.join(pwd, "site"),
          opt: [],
        ),
      )
      msg
    }
    use _ <- result.try(format_html)

    let update_css = {
      use #(_ecode, msg) <- result.map_error(
        shellout.command(run: "just", with: ["build-css"], in: pwd, opt: []),
      )
      msg
    }

    use _ <- result.try(update_css)

    let _copy_static = {
      simplifile.copy_directory(
        filepath.join(pwd, "public"),
        filepath.join(pwd, "site/assets"),
      )
      |> file_err_to_string("Couldn't copy static assets")
    }
  }

  do_res
  |> result.unwrap_error("pipeline executed successfully" |> ansi.green)
  |> io.println
}

fn build_site(curr_dir: String) -> Result(Nil, String) {
  let tag_config = dict.from_list([])

  let web_ctx =
    web.Context(
      tagg_config.Tagg(filepath.join(curr_dir, "views"), tag_config),
      filepath.join(curr_dir, "public"),
      "test",
      filepath.join(curr_dir, "posts"),
    )

  let build_dir = filepath.join(curr_dir, "site")

  // construct a list of request objects
  [
    mk_page("/", build_dir),
    mk_page("/posts", filepath.join(build_dir, "posts")),
    // mk_page("/posts", filepath.join(build_dir, "posts")),
  ]
  // add a page for each of the blog posts
  |> list.append({
    posts.list_posts(web_ctx.posts_dir)
    |> list.map(fn(post_name) {
      let outdir =
        build_dir |> filepath.join("posts") |> filepath.join(post_name)
      mk_page("/posts/" <> post_name, outdir)
    })
  })
  // feed each through the request handler
  |> list.map(fn(page) {
    let res = router.handle_request(page.req, web_ctx)
    PageRes(res, page.path, page.file)
  })
  |> list.try_each(render_url)
}

type PagePlan {
  Page(req: wisp.Request, path: String, file: String)
}

type PageResponse {
  PageRes(res: wisp.Response, path: String, file: String)
}

fn mk_page(url: String, path: String) -> PagePlan {
  let req = testing.get(url, [])
  Page(req, path, "index.html")
}

// res: the web request to save
// outfile: the resultant filepath to create
// Renders HTML for a given route and saves it to the provided filepath
fn render_url(pres: PageResponse) -> Result(Nil, String) {
  let outfile = filepath.join(pres.path, pres.file)
  use _mk_dir <- result.try(
    simplifile.create_directory_all(pres.path)
    |> file_err_to_string("Couldn't create directory"),
  )
  let setup =
    simplifile.create_file(outfile)
    |> result.try_recover(fn(_) {
      use _res <- result.try(
        simplifile.delete(outfile)
        |> file_err_to_string("Couldn't delete file"),
      )
      simplifile.create_file(outfile)
      |> file_err_to_string("Couldn't create new recovery file")
    })

  use _ <- result.try(setup)

  pres.res
  |> testing.string_body
  |> fn(con) { simplifile.write(outfile, con) }
  |> file_err_to_string("Couldn't write content to file")
}

fn file_err_to_string(res: Result(Nil, simplifile.FileError), msg: String) {
  res
  |> result.map_error(fn(e) {
    let repr = e |> simplifile.describe_error
    msg <> ": " <> repr
  })
}
