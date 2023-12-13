#! /bin/bash

#define icons for workspaces 1-5
ic=(0      )

workspaces() {

	unset -v \
  o1 o2 o3 o4 o5 \
  f1 f2 f3 f4 f5

# Get occupied workspaces and remove workspace -99 aka scratchpad if it exists
a="$(hyprctl workspaces | grep ID | awk '{print $3}')"
a="$(echo "${a//-99/}" | sed '/^[[:space:]]*$/d')"
ows="$(hyprctl workspaces -j | jq '.[] | del(select(.id == -99)) | .id')"

for num in $ows; do
	export o"$num"="$num"
done

# Get Focused workspace for current monitor ID
arg="$1"
num="$(hyprctl monitors -j | jq --argjson arg "$arg" '.[] | select(.id == $arg).activeWorkspace.id')"
export f"$num"="$num"

echo 	"(eventbox :onscroll \"echo {} | sed -e 's/up/-1/g' -e 's/down/+1/g' | xargs hyprctl dispatch workspace\" \
          (box	:class \"workspace\"	:orientation \"h\" :space-evenly \"false\" 	\
              (button :onclick \"scripts/dispatch.sh 1\" :class \"w0$o1$f1\" \"${ic[1]} ₁\") \
              (button :onclick \"scripts/dispatch.sh 2\" :class \"w0$o2$f2\" \"${ic[2]} ₂\") \
              (button :onclick \"scripts/dispatch.sh 3\" :class \"w0$o3$f3\" \"${ic[3]} ₃\") \
              (button :onclick \"scripts/dispatch.sh 4\" :class \"w0$o4$f4\" \"${ic[4]} ₄\") \
              (button :onclick \"scripts/dispatch.sh 5\" :class \"w0$o5$f5\" \"${ic[5]} ₅\") \
          )\
        )"
}

workspaces $1 
socat -u UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock - | while read -r; do 
workspaces $1
done
