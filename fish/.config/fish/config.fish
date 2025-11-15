if status is-interactive
    # Commands to run in interactive sessions can go here
end

function open_project
    cd ~/Documents/Projects/$argv[1]
    code .
end

function berff
    bundle exec rspec $argv[1] --fail-fast
end

function ber
    bundle exec rspec $argv[1]
end

function mrm
    bin/rails db:migrate
    bin/rails db:rollback
    bin/rails db:migrate
end

if test -x ~/.local/bin/mise
    ~/.local/bin/mise activate fish | source
end

# pnpm
set -gx PNPM_HOME /Users/saalik/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

fish_add_path /opt/homebrew/opt/libpq/bin

set -gx EDITOR hx
set -gx VISUAL hx
