import blog/posts

/// returns the generated html of the posts page
pub fn render_posts_page(posts_dir: String) -> Result(String, Nil) {
  let _posts = posts.list_posts(posts_dir)
  Ok("test")
}
