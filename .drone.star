def main(ctx):
    # Config

    # Version shown as latest in generated documentations
    # It's fine that this is out of date in version branches, usually just needs
    # adjustment in master/deployment_branch when a new version is added to site.yml
    latest_version = "2.8"

    # Current version branch (used to determine when changes are supposed to be pushed)
    # pushes to base_branch will trigger a build in deployment_branch but pushing
    # to fix-typo branch won't
    base_branch = latest_version

    # Version branches never deploy themselves, but instead trigger a deployment in deployment_branch
    # This must not be changed in version branches
    deployment_branch = "master"

    return [
        build(ctx, latest_version, deployment_branch, base_branch),
        trigger(ctx, latest_version, deployment_branch, base_branch),
    ]

def build(ctx, latest_version, deployment_branch, base_branch):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "documentation",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "cache-restore",
                "pull": "always",
                "image": "plugins/s3-cache:1",
                "settings": {
                    "endpoint": from_secret("cache_s3_endpoint"),
                    "access_key": from_secret("cache_s3_access_key"),
                    "secret_key": from_secret("cache_s3_secret_key"),
                    "restore": "true",
                },
            },
            {
                "name": "docs-deps",
                "pull": "always",
                "image": "owncloudci/nodejs:14",
                "commands": [
                    "yarn install",
                ],
            },
            {
                "name": "docs-validate",
                "pull": "always",
                "image": "owncloudci/nodejs:14",
                "commands": [
                    "yarn validate",
                ],
            },
            {
                "name": "docs-build",
                "pull": "always",
                "image": "owncloudci/nodejs:14",
                "commands": [
                    "yarn antora",
                ],
            },
            {
                "name": "docs-pdf",
                "pull": "always",
                "image": "owncloudci/asciidoctor:latest",
                "commands": [
                    "bin/makepdf -m",
                ],
            },
            {
                "name": "cache-rebuild",
                "pull": "always",
                "image": "plugins/s3-cache:1",
                "settings": {
                    "endpoint": from_secret("cache_s3_endpoint"),
                    "access_key": from_secret("cache_s3_access_key"),
                    "secret_key": from_secret("cache_s3_secret_key"),
                    "rebuild": "true",
                    "mount": [
                        "node_modules",
                    ],
                },
                "when": {
                    "event": [
                        "push",
                        "cron",
                    ],
                    "branch": [
                        deployment_branch,
                        base_branch,
                    ],
                },
            },
            {
                "name": "cache-flush",
                "pull": "always",
                "image": "plugins/s3-cache:1",
                "settings": {
                    "endpoint": from_secret("cache_s3_endpoint"),
                    "access_key": from_secret("cache_s3_access_key"),
                    "secret_key": from_secret("cache_s3_secret_key"),
                    "flush": "true",
                    "flush_age": "14",
                },
                "when": {
                    "event": [
                        "push",
                        "cron",
                    ],
                    "branch": [
                        deployment_branch,
                        base_branch,
                    ],
                },
            },
            {
                "name": "upload-pdf",
                "pull": "always",
                "image": "plugins/s3-sync:1",
                "settings": {
                    "bucket": "uploads",
                    "endpoint": "https://doc.owncloud.com",
                    "access_key": from_secret("docs_s3_access_key"),
                    "secret_key": from_secret("docs_s3_secret_key"),
                    "path_style": "true",
                    "source": "build/",
                    "target": "/deploy",
                },
                "when": {
                    "event": [
                        "push",
                        "cron",
                    ],
                    "branch": [
                        deployment_branch,
                        base_branch,
                    ],
                },
            },
            {
                "name": "notify",
                "pull": "if-not-exists",
                "image": "plugins/slack",
                "settings": {
                    "webhook": from_secret("slack_webhook_private"),
                    "channel": "documentation",
                },
                "when": {
                    "event": [
                        "push",
                        "cron",
                    ],
                    "status": [
                        "failure",
                    ],
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/%s" % deployment_branch,
                "refs/heads/%s" % base_branch,
                "refs/tags/**",
                "refs/pull/**",
            ],
        },
    }

def trigger(ctx, latest_version, deployment_branch, base_branch):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "trigger",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "clone": {
            "disable": True,
        },
        "steps": [
            {
                "name": "trigger-docs",
                "pull": "always",
                "image": "plugins/downstream",
                "settings": {
                    "server": "https://drone.owncloud.com",
                    "token": from_secret("drone_token"),
                    "fork": "true",
                    "repositories": [
                        "owncloud/docs@master",
                    ],
                },
            },
        ],
        "depends_on": [
            "documentation",
        ],
        "trigger": {
            "ref": [
                "refs/heads/%s" % deployment_branch,
                "refs/heads/%s" % base_branch,
            ],
        },
    }

def from_secret(name):
    return {
        "from_secret": name,
    }
