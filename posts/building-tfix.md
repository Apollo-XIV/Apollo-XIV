---
title = "Why I made Tfix, a Terraform wrapper for Nix"
abstract = "A.K.A. how spite drove me to port Terraform into a completely different language."
date = "28/07/2025"
---

Terraform as a language and tool can be incredibly powerful—but also deeply frustrating. There’s a strict ceiling to programmability before the code becomes borderline incomprehensible. Some values can’t be computed at all, requiring static values before evaluation. And its weakness at managing large infrastructure projects has led to tools like Terragrunt.

But more than that, I personally dislike HCL, the main way to interact with Terraform. It’s inconsistent, bulky, and so deeply tailored to one specific way of writing code that doing anything else is just impractical.

Despite all this, Terraform remains the best Infrastructure as Code (IaC) tool out there. The language is flexible *enough*, and the tool is *so reliable* and integrated with *so many APIs* that it often manages resources that only it can. Add in Terragrunt for an extra layer of programmability and multi-state management, and Terraform becomes actually workable for large projects.

That’s what’s most frustrating—it’s almost impossible to move away from. But the status quo won’t last forever. As DevOps and IaC become more integral to development, it’s worth asking: what comes next?

---

I don’t know what the next generation of state management will look like—but I like thinking about it, and I want to see more people thinking outside the box.

Tfix isn’t meant to be *the* solution. It’s a proof of concept. A toy. A sketch of what Terraform might look like if we reimagined it using a completely different configuration language.

For that, I chose Nix.

Nix is a deterministic, functional language built for reproducibility. It’s a full programming language, but one geared toward configuration and package management—making it an interesting fit for infrastructure as code. The expressive power of Nix lets you compose infrastructure in ways HCL simply can’t match without resorting to brittle templating or wrappers.

Tfix is also heavily inspired by Terragrunt. Like Terragrunt, it’s packaged as a CLI wrapper around Terraform. I even borrowed its high-level abstraction pattern—**stacks**, **units**, **modules**—because, frankly, that part works. Where Terragrunt uses YAML or HCL to describe its inputs, Tfix uses native Nix code, compiled down to Terraform-compatible JSON.

---

The resulting format is a bit… cursed, if I’m honest.

I saw an opportunity in Nix to mirror Terraform’s module structure visually, while still generating 100% valid Nix code. The upside is clarity: if you’re coming from Terraform, it feels familiar. You can glance at the structure and roughly understand what’s going on.

The downside is something like an uncanny valley effect. It looks close enough to Terraform that users might assume unsupported features exist, or misunderstand how much of it is “real” Nix. It’s readable, but not always teachable.

Ironically, the way I implemented this limits programmability almost entirely to configuration generation. This isn’t a flaw in Nix—it’s a consequence of Terraform’s design. Without a more granular API, deeper integration just isn’t possible. A more focused effort could push past that ceiling, but Tfix isn’t trying to rewrite Terraform from scratch. It’s a thought experiment, bound by what Terraform exposes.

---

Anyway, here’s what writing infrastructure code looks like in Tfix:

```nix
{tfix, lib, ...}: with tfix.all; mkUnitModule rec {
  example = resource "aws_s3_bucket" {
    bucket_policy = "example-";
  };

  bucket_name = output {
    value = example._ref "bucket_name";
  };
}
```
There’s a lot going on here—most of it buried under heavy abstraction—which makes it tricky to explain exactly what’s happening under the hood. But at a high level: resource and output are Nix functions that generate an intermediate representation (IR) of the desired Terraform blocks. That IR is post-processed into valid Terraform-compatible JSON.

From there, the Tfix CLI steps in: it evaluates the Nix code, emits the final configuration, and runs the Terraform commands you’ve requested. Evaluation uses Nix’s module system, which is far more programmable and expressive than Terraform’s own config logic.

---

There are definite constraints. Terraform only exposes so much, and Tfix works within those boundaries. But building this has been fun. And that’s really what this project is about.

Terraform is stable. Predictable. We know what it can do. But what happens when you let yourself drift a little? What does it look like to write infrastructure code differently—even just to explore what else might be possible?
