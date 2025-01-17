# k8s-ps1.sh

Sourced in `bash` shell it define a variable to add into `$PS1` and declare a toggle (`Ctrl + T`) to enable or disable the shell annotation.

## usage

You can prepend the `$PS1` definition in your `.bashrc` like so, or compose your own `$PS1` with `${__k8s_ps1:-}`:

```bash
PS1="${__k8s_ps1:-}$PS1"
```

Then press `Ctrl+T` or set/unset `K8S_PS1_ENABLED=on`

## customization

Colors can be customized using bash's `case` pattern in another sources file, example:

```bash
K8S_COL_PATTERN_WHITE="*dev*"
K8S_COL_PATTERN_GREEN="*sandbox*"
K8S_COL_PATTERN_YELLOW="*staging*"
K8S_COL_PATTERN_RED="*production*"
K8S_COL_PATTERN_GREY="*minikube*"
```
