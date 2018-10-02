[![Build Status](https://travis-ci.com/Gl0wnet/web-core.svg?token=FL7nHmADxkupBF5E3Sx6&branch=develop)](https://travis-ci.com/Gl0wnet/web-core)
[![codecov](https://codecov.io/gh/Gl0wnet/web-core/branch/development/graph/badge.svg?token=FGUnCmXVXP)](https://codecov.io/gh/Gl0wnet/web-core)

# Glownet core test
 - [Coding Rules](#rules)
 - [Commit Message Guidelines](#commit)


## <a name="rules"></a> Coding Rules

To ensure consistency throughout the source code, keep these rules in mind as you are working:

* All features or bug fixes **must be tested**.
* All files **must pass rubocop styleguide**

## <a name="commit"></a> Git Commit Guidelines

We have very precise rules over how our git commit messages can be formatted.  This leads to **more
readable messages** that are easy to follow when looking through the **project history**.  But also,
we use the git commit messages to **generate the change log**.

### Commit Message Format
Each commit message consists of a **header**, a **body** and a **footer**.  The header has a special
format that includes a **type**, a **scope** and a **subject**:

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The **header** is mandatory and the **scope** of the header is optional.

Any line of the commit message cannot be longer 100 characters! This allows the message to be easier
to read on GitHub as well as in various git tools.

### Amends
Ammends are only allowed in 1 of 2 cases:
 * If it is a hotfix commit straight to develop, only do amends when commit is not pushed. 
 * If it is on a feature branch, amends are always allowed

### Revert
If the commit reverts a previous commit, it should begin with `revert: `, followed by the header of the reverted commit. In the body it should say: `This reverts commit <hash>.`, where the hash is the SHA of the commit being reverted.

### Type
Must be one of the following:

* **feature**: A new feature
* **fix**: A bug fix
* **docs**: Documentation only changes
* **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing
  semi-colons, etc)
* **refactor**: A code change that neither fixes a bug nor adds a feature
* **perf**: A code change that improves performance
* **test**: Adding missing tests
* **chore**: Changes to the build process or auxiliary tools and gems

### Scope
The scope could be anything specifying place of the commit change. For example `asset_tracker`,
`customer.rb`, `device_manager`, `missing_transactions`, `credit_transactions`, `customer_area`, `admin_panel`, etc...

### Subject
The subject contains succinct description of the change:

* use the imperative, present tense: "change" not "changed" nor "changes"
* don't capitalize first letter
* no dot (.) at the end

### Body
Just as in the **subject**, use the imperative, present tense: "change" not "changed" nor "changes".
The body should include the motivation for the change and contrast this with previous behavior.

### Footer
The footer should contain any information about **Breaking Changes** and is also the place to
reference GitHub issues that this commit **Closes**.

**Breaking Changes** should start with the word `BREAKING CHANGE:` with a space or two newlines. The rest of the commit message is then used for this.
