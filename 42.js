var	fs = require('fs'),
	path = require('path'),
	async = require('async'),
	log = require('tiny-logger').init('debug', '[nodebb-plugin-42]'),
	meta = module.parent.require('./meta'),

	FortyTwo = {
		config: {},

		init: function(callback) {
			log.debug('init()');
			var	_self = this,
				fields = [
					'brandLink',
					'navigation',
					'footerHtml'
				],
				defaults = {
					'brandLink': '',
					'navigation': '[]',
					'footerHtml': ''
				},
				hashes = fields.map(function(field) { return 'nodebb-plugin-42:options:' + field });

			meta.configs.getFields(hashes, function(err, options) {
				if (err) throw err;
				var option;
				for (field in options) {
					option = field.slice('nodebb-plugin-42:options:'.length);
					_self.config[option] = option == 'navigation' ? JSON.parse(options[field] || defaults[option]) : options[field] || defaults[option];
				}
				if (typeof callback == 'function') {
					callback();
				}
			});
		},

		reload: function(hookVals) {
			var	is42Plugin = /^nodebb-plugin-42:options:brandLink/;
			if (is42Plugin.test(hookVals.key)) {
				log.debug('reloading...');
				this.init();
			}
		},

		header: function(custom_header, callback) {
			var _self = this;

			async.series([
				function(next) {
					if (!_self.config.initialized) {
						_self.init(next);
					} else {
						next();
					}
				},
				function() {
					(_self.config.navigation || []).forEach(function(item, i) {
						custom_header.navigation.push({
							"class": item.class || '',
							"route": item.href,
							"text": item.text
						});
					});
					callback(null, custom_header);
				}
			]);
		},

		footer: function(custom_footer, callback) {
			var _self = this;

			async.series([
				function(next) {
					if (!_self.config.initialized) {
						_self.init(next);
					} else {
						next();
					}
				},
				function() {
					custom_footer = _self.config.footerHtml || '';

					// todo: much hack, so many scared, wow, --doge, 2013
					if (_self.config.brandLink) {
						custom_footer += '\n<script>\n\t$(function(){ \n'
							+ '\t\t$(".navbar-header .forum-logo").parents("a").eq(0).attr("href", "' + _self.config.brandLink + '"); \n'
							+ '\t\t$(".navbar-header .forum-title").parents("a").eq(0).attr("href", "' + _self.config.brandLink + '"); \n'
							+ '\t});\n</script>';
					}

					callback(null, custom_footer);
				}
			]);
		},

		admin: {
			menu: function(custom_header) {
				custom_header.plugins.push({
					"route": '/plugins/42',
					"icon": 'icon-edit',
					"name": '42'
				});

				return custom_header;
			},
			route: function(custom_routes, callback) {
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
				if (id === 'nodebb-plugin-42') {
					var defaults = [
						{ field: 'brandLink', value: '' },
						{ field: 'navigation', value: '[]' },
						{ field: 'footerHtml', value: '' }
					];

					async.each(defaults, function(optObj, next) {
						meta.configs.setOnEmpty('nodebb-plugin-42:options:' + optObj.field, optObj.value, next);
					});
				}
			}
		}
	};

module.exports = FortyTwo;