import gleam/io
import gleam/string_builder
import gleam_community/ansi
import wisp.{type Request, type Response}

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
