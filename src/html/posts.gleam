import app/web.{type Context}
import blog/posts
import cx
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam_community/ansi
import html/render
import tagg

/// returns the generated html of the posts page
pub fn render_posts_page(web_context: Context) -> Result(String, String) {
  let posts_ctx: Result(List(cx.Context), String) = {
    // list all the post urls, the rest of the block iterates over them
    use post <- list.try_map(posts.list_posts(web_context.posts_dir))

    // turn them into post records
    use post_record <- result.map(posts.get_post(web_context.posts_dir, post))

    // generate the posts context list
    cx.dict()
    |> cx.add_string("title", post_record.title)
    |> cx.add_string("date", post_record.date)
    |> cx.add_string("path", "/posts/" <> post_record.path)
  }

  use ctx_list <- result.try(posts_ctx)

  let ctx =
    cx.dict()
    |> cx.add_string("title", "Posts | Apollo_")
    |> cx.add_list("posts", ctx_list)

  // render out the final page
  tagg.render(web_context.tagg, "posts.html", ctx)
  |> render.tmpl_error_to_string
}

pub fn render_post_page(
  web_context: Context,
  post_path: String,
) -> Result(String, String) {
  posts.get_post(web_context.posts_dir, post_path)
  |> result.map(fn(p) {
    cx.dict()
    |> cx.add_string("title", p.title <> " | Apollo_")
    // |> cx.add_bool("is_dev", web_context.env == "dev")
    |> cx.add(
      "post",
      cx.dict()
        |> cx.add_string("title", p.title)
        |> cx.add_string("content", p.content)
        |> cx.add_string("date", p.date),
    )
  })
  |> result.try(fn(ctx) {
    tagg.render(web_context.tagg, "post.html", ctx)
    |> result.map_error(fn(e) {
      let err =
        e
        |> string.inspect
      err
      |> ansi.red
      |> io.println
      err
    })
  })
}
