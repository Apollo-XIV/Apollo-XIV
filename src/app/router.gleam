import app/web.{type Context}
import filepath
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import html/pages
import shellout
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, web_context: Context) -> Response {
  use req <- web.middleware(req, web_context)

  // reload css on each requeset
  let update_css = {
    use #(_ecode, msg) <- result.map_error(
      shellout.command(
        run: "just",
        with: ["build-css"],
        in: {
          filepath.split(web_context.static_dir)
          |> list.rest()
          |> result.map(list.reverse)
          |> result.try(fn(x) { list.rest(x) })
          |> result.map(list.reverse)
          |> result.map(fn(x) { "/" <> string.join(x, "/") })
          |> result.map(fn(x) {
            x |> io.println
            x
          })
          |> result.lazy_unwrap(fn() { panic })
        },
        opt: [],
      ),
    )
    msg
  }
  update_css
  |> result.unwrap_both
  |> io.println

  case wisp.path_segments(req) {
    [] -> pages.home(req, web_context)
    ["posts"] -> pages.posts(req, web_context)
    ["posts", url] -> pages.post(req, web_context, url)
    _ -> wisp.not_found()
  }
}
