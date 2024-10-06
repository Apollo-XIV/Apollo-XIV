import app/web.{type Context}
import cx
import gleam/http.{Get}
import gleam/io
import gleam/string_builder
import gleam_community/ansi
import html/posts
import tagg
import wisp.{type Request, type Response}

// https://github.com/gleam-wisp/wisp/blob/main/examples/01-routing/src/app/router.gleam
pub fn handle_request(req: Request, web_context: Context) -> Response {
  use req <- web.middleware(req)

  // Wisp doesn't have a special router abstraction, instead we recommend using
  // regular old pattern matching. This is faster than a router, is type safe,
  // and means you don't have to learn or be limited by a special DSL.
  //
  case wisp.path_segments(req) {
    // This matches `/`.
    [] -> home_page(req, web_context)
    ["posts"] -> posts(req, web_context)
    ["post", _n] -> posts(req, web_context)

    // This matches all other paths.
    _ -> wisp.not_found()
  }
}

fn home_page(req: Request, web_context: Context) -> Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- wisp.require_method(req, Get)

  let context = cx.dict()
  // |> cx.add_string("title", "Home | Apollo_")
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

fn posts(req: Request, web_context: Context) -> Response {
  use <- wisp.require_method(req, Get)

  case posts.render_posts_page(web_context.posts_dir) {
    Ok(html) -> {
      wisp.ok()
      |> wisp.html_body(string_builder.from_string(html))
    }
    Error(_) -> wisp.internal_server_error()
  }
}

fn posts_page(req: Request, web_context: Context) -> Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- wisp.require_method(req, Get)

  let context =
    cx.dict()
    |> cx.add_list("events", [
      cx.dict()
        |> cx.add_string("name", "Muse Concert")
        |> cx.add_string("location", "Los Angeles, CA"),
      cx.dict()
        |> cx.add_string("name", "The Killers")
        |> cx.add_string("location", "Las Vegas, NV"),
    ])

  case tagg.render(web_context.tagg, "events.html", context) {
    Ok(html) -> {
      wisp.ok()
      |> wisp.html_body(string_builder.from_string(html))
    }
    Error(err) -> {
      io.debug(err)
      wisp.internal_server_error()
    }
  }
}
