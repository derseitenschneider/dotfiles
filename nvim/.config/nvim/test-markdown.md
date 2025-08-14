# Test Markdown File

This is a test file to demonstrate the render-markdown.nvim plugin functionality.

## Headings

### Level 3 Heading
#### Level 4 Heading
##### Level 5 Heading
###### Level 6 Heading

## Code Blocks

Here's some JavaScript:

```javascript
function greet(name) {
  console.log(`Hello, ${name}!`);
}

greet("World");
```

And some PHP:

```php
<?php
class User {
    private $name;
    
    public function __construct($name) {
        $this->name = $name;
    }
    
    public function getName() {
        return $this->name;
    }
}
```

## Lists and Checkboxes

### Unordered List
- First item
- Second item
  - Nested item
  - Another nested item
- Third item

### Task List
- [x] Completed task
- [ ] Incomplete task
- [x] Another completed task
- [ ] Another incomplete task

## Tables

| Name | Age | City |
|------|-----|------|
| John | 25  | NYC  |
| Jane | 30  | LA   |
| Bob  | 35  | Chicago |

## Callouts

> [!NOTE]
> This is a note callout with important information.

> [!TIP]
> This is a helpful tip for users.

> [!IMPORTANT]
> This highlights something very important.

> [!WARNING]
> This is a warning about potential issues.

> [!CAUTION]
> This indicates something that requires caution.

## Quotes

> This is a regular blockquote.
> It can span multiple lines.

## Links

Here's a [link to Google](https://google.com) and an image:

![Alt text](https://via.placeholder.com/150)

## Horizontal Rule

---

That's the end of the test file!