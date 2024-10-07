import app/web.{type Context}
import cx
import gleam/http.{Get}
import gleam/io
import gleam/string_builder
import gleam_community/ansi
import html/posts
import tagg
import wisp.{type Request, type Response}

pub fn home(req: Request, web_context: Context) -> Response {
  use <- wisp.require_method(req, Get)

  let context =
    cx.dict()
    |> cx.add_string("title", "Home | Apollo_")
    |> cx.add_bool("is_dev", web_context.env == "dev")
  // |> cx.add("settings", cx.add_string(cx.dict(), "className", "myClass"))
  // |> cx.add_string("company_address1", "123 Main St")
  // |> cx.add_list("people", [
  //   cx.add_strings(cx.dict(), "Nicknames", ["Jane", "Jill"]),
  // ])

  case tagg.render(web_context.tagg, "index.html", context) {
    Ok(html) -> {
      wisp.ok()
      |> wisp.html_body(string_builder.from_string(html))
    }
    Error(_e) -> {
      "Couldn't render the template"
      |> ansi.red
      |> io.println
      wisp.internal_server_error()
    }
  }
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
