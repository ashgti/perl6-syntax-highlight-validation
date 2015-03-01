#!/usr/bin/env perl6

use v6;

sub check-dependencies {
  if qx/highlights -v/.chomp ~~ '' {
    die "System command 'highlights' missing, please install (e.g. 'npm " +
        "install highlights')";
  }

  if qx/apm -v/.chomp ~~ '' {
    die "System command 'apm' missing, please install from https://atom.io/" +
        " and install the 'apm' system command.";
  }

  if qx/lessc -v/.chomp ~~ '' {
    die "npm install -g less";
  }
}

my $syntax-validation-template = q:to /END/;
<!DOCTYPE html>
<html>
  <head>
    <title>%1$s</title>
    <link rel="stylesheet" type="text/css" href="./%2$s.css" />
  </head>

  <body>
    <h1>Syntax Example for: <strong>%1$s</strong>

    %3$s
  </body>
</html>
END

sub MAIN(:i(:$init), :t(:$theme) = 'atom-light-syntax', :o(:$output) = 'output', *@example-files) {
  check-dependencies;

  if $init {
    qx<apm init --package language-perl --convert ./perl.tmbundle>;
    qx<npm install ./language-perl>;
  }

  if $output.IO !~~ :d {
    mkdir($output);
  }

  shell(qqw{lessc --include-path="themes/$theme/styles" "themes/$theme/index.less" "$output/$theme.css"});

  for @example-files -> $example {
    my $highlight = qqx<node ./highlight-p6.js --scope source.perl6 {$example}>;
    spurt "$output/$example.html", sprintf($syntax-validation-template, $example, $theme, $highlight);
  }
}
