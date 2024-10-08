import app/web.{type Context}
import cx
import gleam/io
import gleam/result
import gleam/string
import gleam/string_builder
import gleam_community/ansi
import tagg
import tagg_error.{type TaggError}
import wisp.{type Response}

pub fn page_layout(
  inner_content: String,
  title,
  web_context: Context,
) -> Result(String, String) {
  let ctx =
    cx.dict()
    |> cx.add_string("title", title)
    |> cx.add_string("inner_content", inner_content)
  tagg.render(web_context.tagg, "base.html", ctx)
  |> tmpl_error_to_string
}

pub fn render_response(maybe_html: Result(String, String)) -> Response {
  case maybe_html {
    Ok(html) -> {
      wisp.ok()
      |> wisp.html_body(string_builder.from_string(html))
    }
    Error(e) -> {
      e
      |> ansi.red
      |> io.println
      wisp.internal_server_error()
    }
  }
}

pub fn tmpl_error_to_string(
  result: Result(String, TaggError),
) -> Result(String, String) {
  result
  |> result.map_error(fn(e) {
    "Couldn't render the template: " <> e |> string.inspect
  })
}
