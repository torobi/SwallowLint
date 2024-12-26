Pod::Spec.new do |s|
  s.name                      = 'SwallowLint'
  s.version                   = '0.1.2'
  s.summary                   = 'It is a simple, easily extensible linter for Swift.'
  s.homepage                  = 'https://github.com/torobi/SwallowLint'
  s.authors                   = { 'torobi' => '' }
  s.license                   = { type: 'MIT', file: 'LICENSE' }
  s.source                    = { http: "https://github.com/torobi/SwallowLint/releases/download/0.1.2/portable_swallowlint.zip" }
  s.preserve_paths            = "*"
  s.exclude_files             = '**/file.zip'
  s.ios.deployment_target     = '11.0'
  s.macos.deployment_target   = '10.13'
  s.tvos.deployment_target    = '11.0'
  s.watchos.deployment_target = '7.0'
end
