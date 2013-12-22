var	fs = require('fs'),
	path = require('path'),
	meta = module.parent.require('./meta'),

	FortyTwo = {
		config: {},
		init: function() {
			console.log('init');

			var	_self = this,
				fields = [
					'brandLink',
					'navigation'
				],
				defaults = {
					'brandLink': '',
					'navigation': '[]'
				},
				hashes = fields.map(function(field) { return 'nodebb-plugin-42:options:' + field });

			meta.configs.getFields(hashes, function(err, options) {
				var	option;
				for(field in options) {
					if (options.hasOwnProperty(field)) {
						option = field.slice(25);

						if (!options[field]) {
							_self.config[option] = defaults[option];
						} else {

						}
					}
				}
			});
		},
		reload: function(hookVals) {
			console.log('reload');
			var	is42Plugin = /^nodebb-plugin-42/;
			if (is42Plugin.test(hookVals.key)) {
				this.init();
			}
		},
		header: function(custom_header, callback) {
			console.log('header');
			return custom_header;
		},

		footer: function(custom_footer, callback) {
			console.log('footer');
			return custom_footer;
		},

		admin: {
			menu: function(custom_header, callback) {
				console.log('admin.menu');
				custom_header.plugins.push({
					"route": '/plugins/42',
					"icon": 'icon-edit',
					"name": '42'
				});

				return custom_header;
			},
			route: function(custom_routes, callback) {
				console.log('admin.route');
				fs.readFile(path.join(__dirname, 'public/templates/admin.tpl'), function(err, tpl) {
					if (err) console.log(err);

					custom_routes.routes.push({
						route: '/plugins/42',
						method: "get",
						options: function(req, res, callback) {
							callback({
								req: req,
								res: res,
								route: '/plugins/42',
								name: FortyTwo,
								content: tpl
							});
						}
					});

					callback(null, custom_routes);
				});
			},
			activate: function(id) {
				console.log('admin.activate');
				if (id === 'nodebb-plugin-42') {
					var defaults = [
						{ field: 'brandLink', value: '' },
						{ field: 'navigation', value: '[]' }
					];

					async.each(defaults, function(optObj, next) {
						meta.configs.setOnEmpty('nodebb-plugin-42:options:' + optObj.field, optObj.value, next);
					});
				}
			}
		}
	};

module.exports = FortyTwo;