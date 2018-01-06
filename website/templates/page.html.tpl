<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{{.Title}} &mdash; VT6</title>
  <meta property="og:type" content="website" />
  <meta property="og:title" content="{{.Title}} &mdash; VT6" />
  {{ if .Description -}}
  <meta name="description" content="{{.Description}}">
  <meta property="og:description" content="{{.Description}}" />
  {{ end -}}
  <link rel="canonical" href="https://vt6.io/{{.Path}}/" />
  <meta property="og:url" content="https://vt6.io/{{.Path}}/" />
  <link rel="stylesheet" type="text/css" href="/static/vt6.css" />
</head>
<body class="{{if .IsDraft}}draft {{end}}">
  <header>
    <h1>
      <a href="/"><img alt="VT6" src="/static/logo-dark-wide.png" /></a><div><span>A modern protocol for virtual terminals</span></div>
    </h1>
  </header>
  <nav>
    {{ if .UpwardsNavigation -}}
    <ul class="breadcrumb">
      {{ range .UpwardsNavigation }}<li><a href="{{.URLPath}}">{{.Caption}}/</a></li>{{ end }}
    </ul>
    {{- end -}}
    <ul class="children">
      {{ range .DownwardsNavigation }}<li><a href="{{.URLPath}}">{{.Caption}}/</a></li>{{ end }}
    </ul>
  </nav>
  <div class="white">
    {{ if .TableOfContentsHTML }}<aside>{{ .TableOfContentsHTML }}</aside>{{ end }}
    {{ if .IsDraft }}<div id="draft">Draft</div><main class="draft">{{ else }}<main>{{ end }}
      {{ .ContentHTML }}
    </main>
  </div>
  <script type="text/javascript" src="/static/reader.js"></script>
</body></html>
