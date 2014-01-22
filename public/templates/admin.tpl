<script src="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/codemirror.js"></script>
<link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/codemirror.css">
<script src="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/mode/xml/xml.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/mode/javascript/javascript.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/mode/htmlmixed/htmlmixed.js"></script>

<style>
	.form .note {
		color: grey;
		font-weight: 400;
		font-size: 11px;
	}
	.form .btn-add,
	.form .link-input {
		display: inline-block;
		width: 140px;
	}
	.form .link .btn-remove {
		margin: 0 10px;
	}
	.form .btn-add {
		width: 40px;
	}
	.form input.invalid {
		border:1px solid #f00;
	}
	.form ol.links {
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

<h1>Plugin <a target="_blank" href="http://goo.gl/kZJ6On">42</a> - Settings Page</h1>
<hr />

<form class="form forty-two">

	<div class="form-group">
		<label for="brandUrl">
			<p>Replace the NodeBB brand Link *</p>
            <input class="form-control" type="text" placeholder="http://site.com" id="brandUrl" value="{brandUrl}"/>
			<div class="note">leave blank to keep the NodeBB's default</div>
		</label>
	</div>

	<div class="form-group">
		<label for="links">
			<p>Add external links items</p>
			<input type="text" class="form-control link-input link-text" placeholder="Text" />
			<input type="text" class="form-control link-input link-href" placeholder="http://site.com" />
			<input type="text" class="form-control link-input link-icon-class" placeholder="fa-icon" />
			<input type="text" class="form-control link-input link-title" placeholder="Title" />
			<input type="text" value="visible-xs-inline" class="form-control link-input link-text-class" placeholder="Span Class" />
			<button class="btn btn-sm btn-default btn-add inline" type="button" title="Add link">
				<i class="fa fa-plus"></i>
			</button>
			<div class="note">
				Use these to links back your site or blog or whatever, try to limit to 4 or 5, depending on your theme of course. <br/>
				Find the list of icons class at <a href="http://fontawesome.io/icons/" target="_blank">fontawesome.io</a>.
				You can use an icon, a text or both, but if you want to show the <b>text</b> on <b>desktop</b> as well,
				remove the <code>visible-xs-inline</code>, otherwise it will hide on desktop
			</div>
			<ol class="links">
			<!-- BEGIN links -->
            	<li class="link">
            		<a target="_blank" href="{links.href}">
            			<!-- IF links.iconClass -->
            				<i class="fa {links.iconClass}"></i>
            			<!-- ENDIF links.iconClass -->
            			<span class="{links.textClass}">{links.text}</span>
            		</a>
            		<i class="fa fa-times btn-remove transparent hand"></i>
            		</span>
            	</li>
			<!-- END links -->
			</ol>
		</label>
	</div>

	<div class="form-group">
		<label for="headHtml">
			<p>Append custom HTML to the head *</p>
			<textarea class="form-control" name="code" id="headHtml">{headHtml}</textarea>
			<div class="note"><b>Use double quotes " for your html tag's attributes, till <a href="https://github.com/akhoury/nodebb-plugin-42/issues/1">issue#1</a> is resolved.</b> -- Leave blank to do nothing</div>
		</label>
	</div>

	<div class="form-group">
		<label for="footerHtml">
			<p>Prepend custom HTML to the footer</p>
			<textarea class="form-control" name="code" id="footerHtml">{footerHtml}</textarea>
			<div class="note"><b>Use double quotes " for your html tag's attributes, till <a href="https://github.com/akhoury/nodebb-plugin-42/issues/1">issue#1</a> is resolved.</b> -- Leave blank to do nothing</div>
		</label>
	</div>


	<div class="form-group">
		<label for="copyright">
			<p>Replace the NodeBB Copyright HTML *</p>
            <textarea class="form-control" name="code" id="copyright">{copyright}</textarea>
			<div class="note"><b>Use double quotes " for your html tag's attributes, till <a href="https://github.com/akhoury/nodebb-plugin-42/issues/1">issue#1</a> is resolved.</b> -- leave blank to keep the NodeBB's default - I highly recommend linking to <a target="_blank" href="http://www.nodebb.com">NodeBB</a> to show some gratitude.</div>
		</label>
	</div>

	<div class="form-group">
		<label for="bodyAppend">
			<p>Append HTML to the body on document.ready *</p>
            <textarea class="form-control" name="code" id="bodyAppend">{bodyAppend}</textarea>
			<div class="note"><b>Use double quotes " for your html tag's attributes, till <a href="https://github.com/akhoury/nodebb-plugin-42/issues/1">issue#1</a> is resolved.</b> - leave blank to do nothing.</div>
		</label>
	</div>

    <hr />

	<p><small>* It's hacky, NodeBB doesn't support that natively, so <a href="https://github.com/akhoury/nodebb-plugin-42/issues" target="_blank">file an issue</a> if something goes wrong after a NodeBB update</small></p>
	<p><small>All HTML Editors by the awesome <a href="http://codemirror.net/" target="_blank">codemirror</a></small></p>

    <hr />

	<button class="btn btn-lg btn-primary" id="save">Save</button>
</form>

<script type="text/javascript">
        require(['forum/admin/settings'], function(Settings) {

				var form = $('form'),
					codeEditors = {};
					removeNavigationItem = function(e) {
						return $(e.target).parents('li.link').remove() === 42;
					},

					trim = function(str) {
						return (str || '').replace(/^\s\s*/, '').replace(/\s\s*$/, '');
					},

					appendNavigationItem = (function() {
						var $ol = form.find('ol.links'),
							$text = form.find('input.link-text'),
							$href = form.find('input.link-href'),
							$iconClass = form.find('input.link-icon-class'),
							$textClass = form.find('input.link-text-class'),
							$title = form.find('input.link-title');

						return function(link) {

							// if link hash is not passed, create one from the input fields
							// then lightly validate
							if(!link || link.type == 'click') {
								link = {
									text: $text.val(),
									href: $href.val(),
									iconClass: $iconClass.val(),
									textClass: $textClass.val(),
									title: $title.val()
								};

                                form.find('label[for="links"] .invalid').removeClass('invalid');
								if (!link.href) {
									form.find('input.link-href').addClass('invalid');
									return false;
								}
								if (!link.text && !link.iconClass) {
									form.find('input.link-text').addClass('invalid');
									form.find('input.link-icon-class').addClass('invalid');
									return false;
								}
							}

                            // create the li, then append to list
							var $li = $('<li />').addClass('link'),
							$a = $('<a />').attr('href', link.href).attr('title', link.title);
							if (link.iconClass)
								$a.append($('<i />').addClass('fa ' + link.iconClass));
							$li.append($a.append($('<span />').addClass(link.textClass).text(link.text)));
							$li.append('<i class="fa fa-times btn-remove transparent hand"></i>');
							$li.find('.btn-remove').on('click', removeNavigationItem);
							$ol.append($li);

                            // clear fields
							$text.val('');
							$href.val('');
							$iconClass.val('');
							$textClass.val('');
							$title.val('');

							return false;
						};
                	})(),
                	saveOptions = function(e) {
							e.preventDefault();

							var links = [];
							$('ol.links li.link').each(function(index, link) {
								  link = $(link);

								  var linkData = {
									  text: trim(link.find('a').text()),
									  href: link.find('a').attr('href'),
									  iconClass: (link.find('a i').attr('class')|| '').replace('fa ', ''),
									  title: link.find('a').attr('title'),
									  textClass: link.find('a span').attr('class'),
								  };

								  if(linkData.href) {
									  links.push(linkData);
								  }
							});

							$.ajax({
								url: '/api/admin/plugins/42/save',
								type: 'POST',
								data: {
									_csrf: $('#csrf_token').val(),
									options: {
										  links: links,
										  brandUrl: $('#brandUrl').val(),
										  headHtml: codeEditors['headHtml'].getValue(),
										  footerHtml: codeEditors['footerHtml'].getValue(),
										  copyright: codeEditors['copyright'].getValue(),
										  bodyAppend: codeEditors['bodyAppend'].getValue(),
									}
								}
							})
							.done(function(data){
								  app.alert({
										  title: 'Success',
										  message: data.message,
										  type: 'success',
										  timeout: 2000
								  });
							})
							.fail(function(data){
								  app.alert({
										title: 'Error',
										message: data && data.message ? data.message : 'Something went wrong while saving',
										type: 'danger',
										timeout: 2000
									});
							});

				};

				form.find('.btn-remove').on('click', removeNavigationItem);
				form.find('.btn-add').on('click', appendNavigationItem);
                form.find('#save').on('click', saveOptions);

				$('textarea[name="code"]').each(function(i, el) {
					var $el = $(el);
					codeEditors[$el.attr('id')] = CodeMirror.fromTextArea(el, {mode: {name: "htmlmixed"}, tabMode: "indent"});
				});
        });
</script>
