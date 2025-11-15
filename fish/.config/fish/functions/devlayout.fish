function devlayout --description "Open my helix layout"
    kitty @ send-text "hx .\r"
    sleep 0.1
    kitty @ launch --cwd=current --location=vsplit
    kitty @ launch --cwd=current --location=vsplit
end
