import facet
import filepath
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam_community/ansi
import jot
import simplifile
import tom

pub type Post {
  Post(title: String, date: String, path: String, content: String)
}

pub fn list_posts(posts_dir: String) -> List(String) {
  simplifile.read_directory(posts_dir)
  |> result.unwrap([])
  |> list.filter_map(fn(post_url) {
    // remove .md
    post_url
    |> string.split(".")
    |> list.first
  })
}

pub fn get_post(paths_dir: String, path: String) -> Result(Post, String) {
  paths_dir
  |> filepath.join(path <> ".md")
  |> simplifile.read
  |> result.replace_error("Couldn't find path " <> path)
  |> result.try(fn(x) {
    x
    |> facet.parse
    |> result.replace_error("Facet couldn't parse the document" <> x)
  })
  // error if theres no frontmatter
  |> result.try(fn(document) {
    case document.frontmatter {
      // returns the frontmatter and document content in a tuple
      option.Some(f) -> Ok(#(f.content, document.content))
      option.None -> Error("Couldn't find any frontmatter")
    }
  })
  |> result.try(fn(document_pair) {
    Ok({
      let #(frontmatter, content) = document_pair
      let assert Ok(meta) = tom.parse(frontmatter)
      let assert Ok(post_title) = tom.get_string(meta, ["title"])
      let assert Ok(date) = tom.get_string(meta, ["date"])
      let content = jot.to_html(content)
      Post(post_title, date, path, content)
    })
  })
  // |> result.map_error(fn(_e) {
  //   let error = "Couldn't fetch post data"
  //   error
  //   |> ansi.red
  //   |> io.println
  //   error
  // })
}
