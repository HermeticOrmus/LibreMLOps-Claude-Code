# Original hook scripts

These are the original LibreMLOps hook scripts, kept for reference. Claude Code never ran them: they expected the tool name and target as command-line arguments, Claude Code sends hook input as JSON on stdin, and the old `setup.sh` did not register hooks anywhere.

The installable, working versions live in the optional [`libre-mlops-hooks`](../plugins/libre-mlops-hooks) plugin. They read the hook JSON with `jq`, return output in the format Claude Code expects, and write no log files. Install them with:

```
/plugin install libre-mlops-hooks@libre-mlops
```
