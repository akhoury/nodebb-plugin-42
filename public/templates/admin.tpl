
<script src="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/codemirror.js"></script>
<link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/codemirror.css">
<script src="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/mode/xml/xml.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/mode/javascript/javascript.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/mode/htmlmixed/htmlmixed.js"></script>

<style>
	.note-42 {
		color: grey;
		font-weight: 400;
		font-size: 11px;
	}
	.navigation-42-link {
		display: inline-block;
		width: 140px;
	}
	.navigation-42-add {
		width: 40px;
	}
	input.invalid {
		border:1px solid #f00;
	}
	ul.navigation-42-link-list {
		list-style-type: none;
		margin: 10px 0 0 0;
		padding: 0 0 0 15px;
	}
	.hand {
		cursor: hand;
        cursor: pointer;
    }
	.transparent {
	    -ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=50)";
        filter: alpha(opacity=50);
        -moz-opacity: 0.5;
        -khtml-opacity: 0.5;
        opacity: 0.5;
     }
	.transparent:hover {
	    -ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=100)";
        filter: alpha(opacity=100);
        -moz-opacity: 1;
        -khtml-opacity: 1;
        opacity: 1;
	}
	.CodeMirror {
		background: rgb(230, 230, 230);
		max-height: 200px;
	}
	label {
		display: block;
	}
	label[for='copyright'] .CodeMirror {
		max-height: 50px;
	}
</style>

<h1>42 - Settings</h1>
<br />
<form class="form" id="form-42">

	<div class="form-group">
		<label for="brandUrl">
			<p>Replace the NodeBB brand Link *</p>
            <input class="form-control" type="text" placeholder="http://site.com" data-field="nodebb-plugin-42:options:brandUrl" id="brandUrl" />
			<div class="note-42">leave blank to keep the NodeBB's default</div>
		</label>
	</div>

	<div class="form-group">
		<label for="navigation">
			<p>Add external navigation items</p>
			<input type="text" class="form-control hide" data-field="nodebb-plugin-42:options:navigation" id="navigation" />

			<input type="text" class="form-control navigation-42-link navigation-42-link-text" placeholder="Text" />
			<input type="text" class="form-control navigation-42-link navigation-42-link-href" placeholder="http://site.com" />
			<input type="text" class="form-control navigation-42-link navigation-42-link-icon-class" placeholder="fa-icon" />
			<input type="text" class="form-control navigation-42-link navigation-42-link-title" placeholder="Title" />
			<input type="text" class="form-control navigation-42-link navigation-42-link-text-class" placeholder="<span> Class" />

			<button class="btn btn-sm btn-default navigation-42-link navigation-42-add" type="button" title="Add link">
				<i class="fa fa-plus"></i>
			</button>
			<div class="note-42">
				Use these to links back your site or blog or whatever, try to limit to 4 or 5, depending on your theme of course. <br/>
				Find the list of icons class at <a href="http://fontawesome.io/icons/" target="_blank">fontawesome.io</a>. You can use an icon, a text or both.
			</div>
			<ul class="navigation-42-link-list"></ul>

			<span class="navigation-remove-html-holder hide">
            	<i class="fa fa-times navigation-42-remove transparent hand"></i>
            </span>
		</label>
	</div>

	<div class="form-group">
		<label for="footerHtml">
			<p>Prepend custom HTML to the footer</p>
			<textarea class="form-control" name="code" data-field="nodebb-plugin-42:options:footerHtml" id="footerHtml"></textarea>
			<div class="note-42">Leave blank to do nothing</div>
		</label>
	</div>


	<div class="form-group">
		<label for="copyright">
			<p>Replace the NodeBB Copyright HTML *</p>
            <textarea class="form-control" name="code" data-field="nodebb-plugin-42:options:copyright" id="copyright"></textarea>
			<div class="note-42">leave blank to keep the NodeBB's default - I highly recommend linking to <a target="_blank" href="http://www.nodebb.com">NodeBB</a> to show some gratitude.</div>
		</label>
	</div>

	<div class="form-group">
		<label for="bodyAppend">
			<p>Append HTML to the body on document.ready *</p>
            <textarea class="form-control" name="code" data-field="nodebb-plugin-42:options:bodyAppend" id="bodyAppend"></textarea>
			<div class="note-42">leave blank to do nothing.</div>
		</label>
	</div>

    <hr />

	<p><small>* It's hacky, NodeBB doesn't support that natively, so <a href="https://github.com/akhoury/nodebb-plugin-42/issues" target="_blank">file an issue</a> if it stops working after a NodeBB update</small></p>
	<p><small>HTML Editors by <a href="http://codemirror.net/" target="_blank">codemirror</a></small></p>

    <hr />

	<!-- nbb pls -->
	<button class="btn btn-lg btn-primary" id="save-42">Save</button>
	<button class="btn btn-lg btn-primary hide" id="save">Save</button>


</form>

<script type="text/javascript">
 	$(function(){
    	var form = $('#form-42'),
			save42Btn = form.find('#save-42'),
			saveBtn = form.find('#save'),

			footerHtmlEditor,
			copyrightEditor,
			bodyAppendEditor,

			trim = function (str){
				return (str || '').replace(/^\s\s*/, '').replace(/\s\s*$/, '');
			},

			parse = function(str){
				try {
					str = JSON.parse(str);
				} catch (e) {
					str = null;
				}
				return str;
			},

			removeNavigationItem = function(e) {
				var li = $(e.target).parents('li.navigation-42-link-item');
    			li.remove();
			},

			appendNavigationItem = (function(list, navMinusIcon) {
				var textField = form.find('input.navigation-42-link-text');
				var hrefField = form.find('input.navigation-42-link-href');
				var iconClassField = form.find('input.navigation-42-link-icon-class');
				var textClassField = form.find('input.navigation-42-link-text-class');
				var titleField = form.find('input.navigation-42-link-title');

				return function(link, order) {

					textField.val('');
					hrefField.val('');
					iconClassField.val('');
					textClassField.val('');
					titleField.val('');

				 	var li = $('<li />').addClass('navigation-42-link-item');
				 	if (order) li.append($('<span />').text(order + '-) '));
                    var a = $('<a />').addClass('navigation-42-link-item-a').attr('href', link.href).attr('title', link.title);

                    if (link.iconClass)
                    	a.append($('<i />').addClass('fa ' + link.iconClass));

                    li.append(a.append($('<span />').addClass(link.textClass).text(link.text)));
                    li.append(navMinusIcon);
                    li.find('.navigation-42-remove').on('click', removeNavigationItem);
                    list.append(li);
				};

			})(form.find('ul.navigation-42-link-list'), form.find('.navigation-remove-html-holder').html());

			window.footerHtmlEditor = footerHtmlEditor;
			window.copyrightEditor = copyrightEditor;
			window.bodyAppendEditor = bodyAppendEditor;

			form.find('.navigation-42-add').on('click', function(e) {
				var list = form.find('ul.navigation-42-link-list');

				var text = form.find('input.navigation-42-link-text').val();
				var iconClass = form.find('input.navigation-42-link-icon-class').val();
				var textClass = form.find('input.navigation-42-link-text-class').val();
				var title = form.find('input.navigation-42-link-title').val();

				form.find('label[for="navigation"] .invalid').removeClass('invalid');

				var href = form.find('input.navigation-42-link-href').val();
				if (!href) {
					form.find('input.navigation-42-link-href').addClass('invalid');
					return false;
				}
				if (!text && !icon) {
					form.find('input.navigation-42-link-text').addClass('invalid');
					form.find('input.navigation-42-link-icon-class').addClass('invalid');
					return false;
				}

				appendNavigationItem({
						text: text,
						href: href,
						iconClass: iconClass,
						textClass: textClass,
						title: title
					}, list.find('li.navigation-42-link-item').length + 1);
			});

			save42Btn.on('click', function(e) {

				// nav Items
				var items = form.find('ul.navigation-42-link-list li.navigation-42-link-item');
				var itemsVal = [];
				items.each(function(i, item) {
					console.log(i);
					var a = $(item).find('a.navigation-42-link-item-a');
                	itemsVal.push({
                			text: a.text(),
                			href: a.attr('href'),
                			title: a.attr('title'),
                			iconClass: (a.find('i').attr('class') || '').split(' ')[1],
                			textClass: a.find('span').attr('class') || ''
                		});
				});
				itemsVal = JSON.stringify(itemsVal);
				form.find('input#navigation').val(itemsVal);

				form.find('textarea#footerHtml').val(footerHtmlEditor.getValue());
				form.find('textarea#copyright').val(copyrightEditor.getValue());
				form.find('textarea#bodyAppend').val(bodyAppendEditor.getValue());

				saveBtn.trigger('click');
			});


			require(['forum/admin/settings'], function(Settings) {
        		Settings.prepare();

        		// set ui nav links
        		var list = form.find('ul.navigation-42-link-list'),
					links = parse(form.find('input#navigation').val());

				if (links && links.length) {
					links.forEach(function(link, i){
						appendNavigationItem(link, i + 1);
					});
				}

				footerHtmlEditor = CodeMirror.fromTextArea(document.getElementById("footerHtml"), {mode: {name: "htmlmixed"}, tabMode: "indent"});
				copyrightEditor = CodeMirror.fromTextArea(document.getElementById("copyright"), {mode: {name: "htmlmixed"}, tabMode: "indent"});
				bodyAppendEditor = CodeMirror.fromTextArea(document.getElementById("bodyAppend"), {mode: {name: "htmlmixed"}, tabMode: "indent"});

				footerHtmlEditor.setValue(trim(form.find('textarea#footerHtml').val()) || "");
				copyrightEditor.setValue(trim(form.find('textarea#copyright').val()) || "");
				bodyAppendEditor.setValue(trim(form.find('textarea#bodyAppend').val()) || "");
        	});
 	});
</script>