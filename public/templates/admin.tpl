
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
	}
</style>

<h1>42 - Settings</h1>
<br />
<form class="form" id="form-42">

	<div class="form-group">
		<label for="brandLink">
			<p>Replace the NodeBB brand Link *</p>
            <input class="form-control" type="text" placeholder="http://site.com" data-field="nodebb-plugin-42:options:brandLink" id="brandLink" />
			<div class="note-42">leave blank to keep the NodeBB's default</div>
		</label>
	</div>

	<div class="form-group">
		<label for="navigation">
			<p>Add external navigation items</p>
			<input type="text" class="form-control hide" data-field="nodebb-plugin-42:options:navigation" id="navigation" />

			<input type="text" class="form-control navigation-42-link navigation-42-link-text" placeholder="Text" />
			<input type="text" class="form-control navigation-42-link navigation-42-link-href" placeholder="Url" />
			<input type="text" class="form-control navigation-42-link navigation-42-link-icon" placeholder="fa-icon" />
			<input type="text" class="form-control navigation-42-link navigation-42-link-title" placeholder="Title" />
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
    		<p>Append custom HTML to the footer</p>
            <textarea class="form-control" data-field="nodebb-plugin-42:options:footerHtml" id="footerHtml" name="code">

            </textarea>
    		<div class="note-42">HTML Editor by <a href="http://codemirror.net/" target="_blank">codemirror</a></div>
    	</label>
    </div>

    <hr />

	<p><small>* It's hacky, NodeBB doesn't support that natively, so <a href="https://github.com/akhoury/nodebb-plugin-42/issues" target="_blank">file an issue</a> if it stops working after a NodeBB update</small></p>

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
				var iconField = form.find('input.navigation-42-link-icon');
				var titleField = form.find('input.navigation-42-link-title');

				return function(link, order) {

					textField.val('');
					hrefField.val('');
					iconField.val('');
					titleField.val('');

				 	var li = $('<li />').addClass('navigation-42-link-item');
				 	if (order) li.append($('<span />').text(order + '-) '));
                    var a = $('<a />').addClass('navigation-42-link-item-a').attr('href', link.href).attr('title', link.title);

                    if (link.icon)
                    	a.append($('<i />').addClass('fa ' + link.icon));

                    li.append(a.append($('<span />').text(link.text)));
                    li.append(navMinusIcon);
                    li.find('.navigation-42-remove').on('click', removeNavigationItem);
                    list.append(li);
				};

			})(form.find('ul.navigation-42-link-list'), form.find('.navigation-remove-html-holder').html());

			form.find('.navigation-42-add').on('click', function(e) {
				var list = form.find('ul.navigation-42-link-list');

				var text = form.find('input.navigation-42-link-text').val();
				var icon = form.find('input.navigation-42-link-icon').val();
				var title = form.find('input.navigation-42-link-title').val();

				form.find('label[for="navigation"] .invalid').removeClass('invalid');

				var href = form.find('input.navigation-42-link-href').val();
				if (!href) {
					form.find('input.navigation-42-link-href').addClass('invalid');
					return false;
				}
				if (!text && !icon) {
					form.find('input.navigation-42-link-text').addClass('invalid');
					form.find('input.navigation-42-link-icon').addClass('invalid');
					return false;
				}

				appendNavigationItem({text: text, href: href, icon: icon, title: title}, list.find('li.navigation-42-link-item').length + 1);
			});

			save42Btn.on('click', function(e) {

				// nav Items
				var items = form.find('ul.navigation-42-link-list li.navigation-42-link-item');
				var itemsVal = [];
				items.each(function(i, item) {
					console.log(i);
					var a = $(item).find('a.navigation-42-link-item-a');
                	itemsVal.push({text: a.text(), href: a.attr('href'), title: a.attr('title'), icon: (a.find('i').attr('class') || '').split(' ')[1]});
				});
				itemsVal = JSON.stringify(itemsVal);
				form.find('input#navigation').val(itemsVal);
				form.find('textarea#footerHtml').val(footerHtmlEditor.getValue());

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
				footerHtmlEditor.setValue(form.find('textarea#footerHtml').val() || "");
        	});
 	});
</script>