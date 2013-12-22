<style>
	.note-42 {
		color: grey;
		font-weight: 400;
		font-size: 11px;
	}
	.btn {
		margin-bottom: 4px;
	}
</style>
<h1>42 - Settings</h1>
<br />
<form class="form" id="form-42">

	<div class="form-group">
		<label for="brandLink">
			<p>Replace the NodeBB brand Link *</p>
            <input type="text" placeholder="http://site.com" data-field="nodebb-plugin-42:options:brandLink" id="brandLink" />
			<div class="note-42">leave blank to keep the NodeBB's default</div>
		</label>
	</div>

	<div class="form-group">
		<label for="navigation">
			<p>Add external navigation items</p>
			<input type="text" class="hide" data-field="nodebb-plugin-42:options:navigation" id="navigation" />

			<input type="text" class="navigation-42-link navigation-42-link-text" placeholder="Link Text">
			<input type="text" class="navigation-42-link navigation-42-link-href" placeholder="Link Href">
			<button class="btn btn-sm btn-default navigation-42-add" type="button" title="Add link">
				<i class="fa fa-plus"></i>
			</button>
			<ul class="navigation-42-link-list"></ul>

			<span class="navigation-remove-html-holder hide">
				<button class="btn btn-sm btn-default navigation-42-remove" type="button" title="Remove link">
            		<i class="fa fa-minus"></i>
            	</button>
            </span>
		</label>
	</div>

	<p><small>* hacky, <a href="https://github.com/akhoury/nodebb-plugin-42/issues">file an issue</a> if it stops working after a NodeBB update</small></p>

	<!-- nbb pls -->
	<button class="btn btn-lg btn-primary" id="save-42">Save</button>
	<button class="btn btn-lg btn-primary hide" id="save">Save</button>


</form>

<script type="text/javascript">
 	$(function(){
    	var form = $('#form-42'),
			save42Btn = form.find('#save-42'),
			saveBtn = form.find('#save'),

			parse = function(str){
				try {
					str = JSON.parse(str);
				} catch (e) {
					str = null;
				}
				return null;
			},

			appendNavigationItem = (function(list, navMinusIcon) {
				return function(link){
				 	var li = $('<li />').addClass('navigation-42-link-item');
                    li.append($('<a/>').addClass('navigation-42-link-item-a').attr('href', link.href).text(link.text));
                    li.append(navMinusIcon);
                    list.append(li);
				};
			})(form.find('ul.navigation-42-link-list'), form.find('navigation-remove-html-holder').html());

			form.find('.navigation-42-add').on('click', function(e){
				var list = form.find('ul.navigation-42-link-list');
				var text = form.find('input.navigation-42-link-text').val();

				form.find('label[for="navigation"] .disabled').removeClass('disabled');
				if (!text) {
					form.find('input.navigation-42-link-text').addClass('disabled');
					return false;
				}
				var href = form.find('input.navigation-42-link-href').val();
				if (!href) {
					form.find('input.navigation-42-link-href').addClass('disabled');
					return false;
				}
				appendNavigationItem({text: text, href: href});
			});

			form.find('.navigation-42-remove').on('click', function(e){
				var li = $(e.target).parents('li.navigation-42-link-item');
				li.remove();
			});

			save42Btn.on('click', function(e) {

				// nav Items
				var items = form.find('ul.navigation-42-link-list li');
				var itemsVal = [];
				items.each(function(i, item){
					var a = $(item).find('a.navigation-42-link-item-a');
                	itemsVal.push({text: a.text(), href: a.attr('href')});
				});
				itemsVal = JSON.stringify(itemsVal);
				form.find('input#navigation').val(itemsVal);

				saveBtn.trigger('click');
			});


			require(['forum/admin/settings'], function(Settings) {
        		Settings.prepare();

        		// set ui nav links
        		var list = form.find('ul.navigation-42-link-list'),
					links = parse(form.find('input#navigation').val());

				if (links && links.length) {
					links.forEach(function(link, i){
						appendNavigationItem(link);
					});
				}
        	});
 	});
</script>