![Hugo logo here](./images/hugo-logo.png)

Generates a site using Hugo, a Fast and Flexible Website Generator.

# Usage

The Task will download [`hugo`](https://gohugo.io/), it if not present on the build machine, and invoke it.
You can fix the Hugo version or use the latest released version from [Hugo Releases](https://github.com/gohugoio/hugo/releases).

The default Hugo _Source_ is `Build.SourcesDirectory`, you have to specify the _Destination_ folder, e.g. `Build.ArtifactStagingDirectory`, where Hugo generates the web site.

You can specify some common options:

- _Base URL_ sets the hostname (and path) to the root, e.g. `http://example.com/`;
- _Include Drafts_ to include content marked as draft;
- _Include Expired_ to include expired content;
- _Include Future_ to include content with publishdate in the future;
- _Use Ugly URLs_ to use `/filename.html` instead of `/filename/`.

![Build Task Arguments screenshot here](./images/BuildTaskArguments.png)

More Information on Hugo on [this site](https://gohugo.io/).

# Release Notes

## 0.9.8

- Initial release
