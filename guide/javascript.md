# Javascript API

Zen comes with a pretty good Javascript API that's based on the
[Mootools][mootools]. This API allows you to display modal windows, markup
editors and so on. On top of that you're free to use everything Mootools and
it's community has to offer.

<div class="note todo">
    <p>
        <strong>Note</strong>: Whenever you're creating Javascript files you
        should use 4 spaces per indentation and refrain from using tabs. 4
        spaces are used as 2 spaces are generally harder to read due to
        Javascript using curly brackets.
    </p>
</div>

## Datepickers

Zen comes with a version of [Mootools Datepicker][mootools datepicker]. To load
this datepicker you must load the asset group ``:datepicker`` in your
controller:

    class Posts < Zen::Controller::AdminController
      map '/admin/posts'

      load_asset_group [:datepicker], [:new, :edit]

      def new

      end

      def edit(id)

      end
    end

For more information on loading assets see {file:asset_management.md Asset
Management}.

In order to use the datepicker you'll have to add the class "date" to your input
elements:

    <input type="text" name="my_date" class="date" />

In order to customize the datepicker you can set the following attributes:

* data-date-format: a custom date format to use for input and output
  values. Set to the format as defined in ``Zen.date_format`` by default.
* data-date-time: when set to "1" or "true" users can also select a time. Set to
  false by default.
* data-date-min: string containing the minimum date.
* data-date-max: string containing the maximum date.

An example of using these attributes is the following:

    <input type="text" name="my_date" class="date" data-date-format="%d-%m-%Y"
    data-date-min="01-01-2012" data-date-max="01-01-2013" />

## Creating Classes

Mootools has a wonderful system that allows you to easily create classes. The
one thing to remember when creating classes is that you should *always* declare
them under a certain namespace. Not doing so might lead to collisions with
classes created by other developers.

Creating a class (including a namespace) works like the following:

    namespace('Foobar');

    Foobar.ClassName = new Class(
    {
        initialize: function()
        {

        }
    });

This allows you to access your class as following:

    var instance = new Foobar.ClassName();

The namespace you're using doesn't really matter as long as you **do not** use
the "Zen" namespace, it's reserved for all the classes that ship with Zen.

It's also important to remember that there's no guarantee Javascript (and CSS)
files are loaded in a particular order. Because of that you should always wrap
your code (except for class declarations and such) in the following code:

    window.addEvent('domready', function()
    {
        // Do something funky!
    });

This function will be executed once the DOM (and thus all the resources) are
fully loaded.

## Available Classes

Out of the box the following classes are available:

* Zen.Window
* Zen.Tabs
* Zen.Hash
* Zen.Editor
* Zen.Editor.Markdown
* Zen.Editor.Textile
* Zen.HtmlTable

The following third-party classes are also provided:

* Picker
* Picker.Date
* Picker.Attach

### Zen.Window

The Window class can be used to display modal windows with (or without) a set of
custom buttons. These windows can be used for displaying pictures, confirmation
messages and so on. In order to display a window you'll need to create a new
instance of the class. The syntax of this looks like the following:

    var some_window = new Zen.Window(content[, options]);

<div class="note deprecated">
    <p>
        <strong>Warning</strong>: When creating an instance of Zen.Window you
        should never save it in a variable named "window" as this is a reserved
        variable that refers to the browser window.
    </p>
</div>

The first parameter is the content to display and can either be plain text or
HTML. The second parameter is an object containing various options that can be
used to customize the window. The following options can be set in this object:

* height: a number indicating a fixed height to use for the window.
* width: the same but for the width.
* title: the title to display in the title bar containing the close button.
* resize: boolean that when set to true allows the user to resize the window.
* move: boolean that when set to true allows the user to move the window around.
* buttons: an array of buttons to display at the bottom of the window.

Creating a new window with some of these options would look something like the
following:

    var some_window = new Zen.Window('Hello, world!', {title: 'This is a window!'});

Note that you're not required to call any extra methods, the window will be
displayed whenever a new instance of the window is created.

Buttons can be added by setting the "buttons" option to an array of objects of
which each object has the following format:

    {
      name:   'foobar',
      label:  'Foobar',
      onClick: function() {}
    }

* name: the name of the button, should be unique as it's used for the class of
  the ``li`` element of the button.
* label: the text displayed in the button.
* onClick: a function that will be called whenever the button is clicked.

### Zen.Tabs

Zen.Tabs can be used to create a tab based navigation menu. Because Zen already
uses this class for all elements that match the selector ``div.tabs ul`` it's
usually not required to manually create an instance of this class.

The syntax of creating an instance of this class looks like the following:

    var tabs = new Zen.Tabs(selector[, options]);

The first parameter is a CSS selector, the second parameter is an object
containing various options to customize the instance. Note that the selector
used should result in a number of ``ul`` elements, not ``div`` elements (or any
other elements).

A short example looks like the following:

    var tabs = new Zen.Tabs('div.my_tabs ul');

The following options can be used to customize the tabs:

* default: a selector used to indicate what tab element should be selected by
  default. Set to ``li:first-child`` by default.

For the tabs system to work properly you'll need to use the right markup for
your fields. Luckily this is as simple as creating a ``<div>`` (or another type
of element) and setting an ID for that element:

    <!-- The markup for your tabs -->
    <div class="tabs">
        <ul>
            <li>
                <a href="#some_id">Some ID</a>
            </li>
        </ul>
    </div>

    <!-- The field to show/hide -->
    <div id="some_id">

    </div>

Keep in mind that for the tab system to work properly the URLs for each tab
should start with a hash sign.

### Zen.Hash

Zen.Hash is a class that can be used to parse and generate shebang/hash bang
URLs. Parsing is done using ``Zen.Hash#parse`` and generating URLs using
``Zen.Hash#getHash``.

Parsing a URL is relatively simple and the end output is similar to how you'd
parse URLs with query string parameters. First create a new instance of this
class:

    var hash = new Zen.Hash('#!/users/active?limit=10');

The supplied string will be parsed straight away and the result can be
retrieved from two attributes:

* segments
* params

The first attribute contains an array with all the URL segments, the second
one is an object containing all the query string parameters. In case of the
above example that would lead to the following data being stored in these
attributes:

    console.log(hash.segments); // => ["users", "active"]
    console.log(hash.params);   // => {limit: '10'}

Keep in mind that calling ``Zen.Hash#parse`` will overwrite existing segments
and parameters.

Generating a full shebang URL is pretty straight forward as well and can be done
by calling ``getHash()``. This method returns a string containing the shebang
URL including the prefix:

    hash.getHash(); // => "#!/users/active?limit=10"

### Zen.Editor

Zen.Editor is the main class used for the markup editor that can be used to more
easily insert markup for all supported languages into a text area. By default
Zen will automatically use the markup editor for all ``textarea`` elements with
a class of ``visual_editor``. The format used for the markup is retrieved from
the column ``data-format`` (this column is required). The attribute
``data-format`` should contain the name of the markup engine to use as defined
in ``Zen.Editor.drivers``. Currently the following are supported:

* markdown
* textile

If an unknown driver is specified the default driver (HTML) will be used
instead.

The markup required for Zen to automatically use the markup editor looks like
the example below.

    <textarea class="visual_editor" data-format="markdown"></textarea>

If you want to manually create an instance of ``Zen.Editor`` you can still do so
but due to the way the system works you shouldn't directly create an instance of
the class as this will prevent the editor from automatically using the correct
driver class. You should use ``Zen.Editor.init`` instead. This method has the
following syntax:

    var editor = Zen.Editor.init(driver, element[, options, buttons]);

The first parameter is a string containing the name of the driver to use. The
second parameter can either be a CSS selector, a collection of elements or a
single element. If the parameter is a CSS selector or a collection of elements
the **first** element will be used, all others will be ignored. The last two
parameters are used for customized options as well as adding custom buttons to
the editor. Currently the editor only supports the following two options:

* width: sets a minimum width on the textarea element.
* height: sets a minimum hight on the textarea element.

Buttons can be added by setting the last parameter to an array. Each button has
the same format as the buttons used in Zen.Window:

    {
      name:   'foobar',
      label:  'Foobar',
      onClick: function() {}
    }

Note that unlike Zen.Window these buttons can't be set in the options object
under the key "buttons". This is because the Options class of Mootools doesn't
actually merge options but instead overwrites existing ones. This would mean
that it would be more difficult to add a default set of buttons as well as
custom ones. Most likely this will change in the future once I find out what the
best way of doing this would be.

Example:

    var editor = Zen.Editor.init(
        'markdown',
        'div#text_editor',
        {
            width: 400
        },
        [
            {
                name:    'custom',
                label:   'Custom',
                onClick: function(editor)
                {
                    console.log("This is a custom button!");
                }
            }
        ]
    );

Functions used for buttons take a single parameter which will contain an
instance of the editor the button belongs to. This makes it easy to insert text
into the textarea:

    function(editor)
    {
        editor.insertAroundCursor({before: '<!--', after: '-->'});
    }

### Zen.HtmlTable

The class Zen.HtmlTable was introduced in Zen 0.2.8 and makes it possible to
sort tables by their columns, check all checkboxes in the first column of a
table and it highlights odd rows. Generally you don't need to use this class
itself but instead you'll be using the markup it accepts in order to modify it's
behavior.

The basic markup for this class is very simple, in fact, it's nothing more than
a regular table with a ``<thead>`` element:

    <table>
        <thead>
            <tr>
                <th>#</th>
                <th>Name</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>2</td>
                <td>Ruby</td>
            </tr>
        </tbody>
    </table>

Zen will automatically detect and use the table and you're good to go. If you
want to modify the behavior you can use a few attributes on certain elements of
the table. The following attributes can be applied to the ``<table>`` element
itself:

* data-sort-index: the index of the ``<th>`` element to sort the table on by
  default. By default this is set to 1 as all tables have a checkbox in the
  first column of each row.

The following attributes can be set on each ``<th>`` element:

* data-sort-parser: the name of the parser to use for sorting the columns. This
  option is directly passed to HtmlTable.Sort and can be any of the parsers
  Mootools has to offer (or one you wrote yourself).

Example:

    <table data-sort-index="1">
        <thead>
            <tr>
                <th>#</th>
                <th data-sort-parser="usernames">Name</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>2</td>
                <td>Ruby</td>
            </tr>
        </tbody>
    </table>

If you want to create a table that should be ignored by Zen.HtmlTable simply
give the ``<table>`` element a class of ``no_sort``:

    <table class="no_sort">
        <thead>
            <tr>
                <th>#</th>
                <th>Name</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>2</td>
                <td>Ruby</td>
            </tr>
        </tbody>
    </table>

This class can also be applied to ``<th>`` elements to ignore just that column
rather than the entire table.

[mootools]: http://mootools.net/
[mootools datepicker]: https://github.com/arian/mootools-datepicker
