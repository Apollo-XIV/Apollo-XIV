import app/web.{type Context}
import cx
import gleam/http.{Get}
import gleam/io
import gleam/result
import gleam/string
import gleam/string_builder
import gleam_community/ansi
import html/posts
import html/render
import tagg
import wisp.{type Request, type Response}

fn page_layout(
  inner_content: String,
  title,
  web_context: Context,
) -> Result(String, String) {
  let ctx =
    cx.dict()
    |> cx.add_string("title", title)
    |> cx.add_string("inner_content", inner_content)
  tagg.render(web_context.tagg, "base.html", ctx)
  |> result.map_error(fn(e) {
    "Couldn't render the template: " <> e |> string.inspect
  })
}

pub fn home(req: Request, web_context: Context) -> Response {
  use <- wisp.require_method(req, Get)

  let ctx = cx.dict()

  let rendered_html = {
    use html <- result.try(
      tagg.render(web_context.tagg, "index.html", ctx)
      |> result.replace_error("Couldn't render the inner page content"),
    )
    use rendered_template <- result.try(
      html
      |> page_layout("Home | Apollo_", web_context),
    )
    Ok(rendered_template)
  }

  rendered_html
  |> render.render_response
}

pub fn posts(req: Request, web_context: Context) -> Response {
  use <- wisp.require_method(req, Get)

  case posts.render_posts_page(web_context) {
    Ok(html) -> {
      wisp.ok()
      |> wisp.html_body(string_builder.from_string(html))
    }
    Error(_) -> wisp.internal_server_error()
  }
}

pub fn post(req: Request, web_context: Context, path: String) -> Response {
  use <- wisp.require_method(req, Get)
  case posts.render_post_page(web_context, path) {
    Ok(html) -> {
      wisp.ok()
      |> wisp.html_body(string_builder.from_string(html))
    }
    Error(_) -> wisp.internal_server_error()
  }
}
