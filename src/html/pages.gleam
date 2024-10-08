import app/web.{type Context}
import cx
import gleam/http.{Get}
import gleam/result
import gleam/string_builder
import html/posts
import html/render
import tagg
import wisp.{type Request, type Response}

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
      |> render.page_layout("Home | Apollo_", web_context),
    )
    Ok(rendered_template)
  }

  rendered_html
  |> render.render_response
}

pub fn posts(req: Request, web_context: Context) -> Response {
  use <- wisp.require_method(req, Get)

  let inner_html =
    posts.render_posts_page(web_context)
    |> result.unwrap_both

  inner_html
  |> render.page_layout("Posts | Apollo_", web_context)
  |> render.render_response
}

pub fn post(req: Request, web_context: Context, path: String) -> Response {
  use <- wisp.require_method(req, Get)

  let inner_html =
    posts.render_post_page(web_context, path)
    |> result.unwrap_both

  inner_html
  |> render.page_layout("Post | Apollo_", web_context)
  |> render.render_response
}
