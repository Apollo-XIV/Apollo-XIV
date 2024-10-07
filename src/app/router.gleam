import app/web.{type Context}
import html/pages
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, web_context: Context) -> Response {
  use req <- web.middleware(req, web_context)

  case wisp.path_segments(req) {
    [] -> pages.home(req, web_context)
    ["posts"] -> pages.posts(req, web_context)
    ["posts", url] -> pages.post(req, web_context, url)
    _ -> wisp.not_found()
  }
}
