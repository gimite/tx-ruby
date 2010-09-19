require "rbconfig"
require "mkmf"

if Config::CONFIG["sitearch"] == "i386-msvcrt" && !arg_config("--force-build")
  # Pre-built binary exists. No need to compile.
  # Cheats on mkmf.rb not to claim about missing Makefile.
  $makefile_created= true
else
  if have_library("stdc++")
    create_makefile("tx_core")
  else
    $stderr.puts("-lstdc++ is required")
    exit(1)
  end
end
