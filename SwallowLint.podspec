Pod::Spec.new do |s|
  s.name                      = 'SwallowLint'
  s.version                   = '0.1.1'
  s.summary                   = 'It is a simple, easily extensible linter for Swift.'
  s.homepage                  = 'https://github.com/torobi/SwallowLint'
  spec.authors                = { 'torobi' }
  s.license                   = { type: 'MIT', file: 'LICENSE' }
  s.source                    = { http: "#{s.homepage}/releases/download/#{s.version}/swallowlint.tar.gz" }
  s.preserve_paths            = '*'
  s.exclude_files             = '**/file.zip'
