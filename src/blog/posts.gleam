import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type Post {
  Post(title: String, date: String, path: String)
}

pub fn list_posts(posts_dir: String) -> List(String) {
  simplifile.read_directory(posts_dir)
  |> result.unwrap([])
  |> list.filter_map(fn(s: String) {
    s
    |> string.split(".")
    |> list.first
  })
}

pub fn get_post(_url: String) -> String {
  "some html content"
}
