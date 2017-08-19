Generates a site using Hugo, a Fast and Flexible Website Generator.

[![Hugo logo here](images/hugo-logo.png)](https://gohugo.io/)

# Usage

The Build Task will download the `hugo` executable, if the version is not already present on the build machine, and invoke it.

You can specify some common options.

- **Source**: relative path from repo root of the Hugo sources, defaults to `Build.SourcesDirectory`, passed as `--source` flag.
- **Destination**: path of Hugo generated site, typically `Build.ArtifactStagingDirectory`, passed as `--destination` flag.
- **Hugo Version**: defines the Hugo version, use `latest`, `0.25.1`, `0.24`, but not `v0.24` (pick valid values from Hugo [Releases](https://github.com/gohugoio/hugo/releases) page). If the preferred version cannot be found, the latest released version will be used instead.
- **Base URL**: sets the hostname (and path) to the root, e.g. `http://example.com/`, passed as `--baseURL` flag.
- **Include Drafts**: to include content marked as draft, passed as `--buildDrafts` flag.
- **Include Expired**: to include expired content, passed as `--buildExpired` flag.
- **Include Future**: to include content with publishdate in the future, passed as `--buildFuture` flag.
- **Use Ugly URLs**: to use `/filename.html` instead of `/filename/`, passed as `--uglyURLs` flag.

![Build Task Arguments screenshot here](images/BuildTaskArguments.png)

More Information on Hugo on [this site](https://gohugo.io/).

# Release Notes

## 0.9.12

- Initial release
