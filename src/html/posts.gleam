import app/web.{type Context}
import blog/posts
import cx
import gleam/io
import gleam/list
import gleam/result
import gleam_community/ansi
import tagg

/// returns the generated html of the posts page
pub fn render_posts_page(web_context: Context) -> Result(String, Nil) {
  let posts = posts.list_posts(web_context.posts_dir)
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  let context =
    cx.dict()
    |> cx.add_string("title", "Posts | Apollo_")
    |> cx.add_bool("is_dev", web_context.env == "dev")
    |> cx.add_list("posts", {
      posts
      |> list.map(fn(title) {
        cx.dict()
        |> cx.add_string("title", title)
      })
    })

  tagg.render(web_context.tagg, "posts.html", context)
  |> result.map_error(fn(_e) {
    "Couldn't render the template"
    |> ansi.red
    |> io.println
  })
  |> result.nil_error
}
