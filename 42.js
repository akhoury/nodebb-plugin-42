var	fs = require('fs'),
	pluginData = require('./plugin.json'),
	path = require('path'),
	async = require('async'),
	log = require('tiny-logger').init(process.env.NODE_ENV === 'development' ? 'debug' : 'info,warn,error', '[' + pluginData.id + ']'),
	meta = module.parent.require('./meta');

(function(Plugin) {
	Plugin.config = {};

	Plugin.init = function(callback){
		log.debug('init()');
		var _self = this,
			hashes = Object.keys(pluginData.defaults).map(function(field) { return pluginData.id + ':options:' + field });

		meta.configs.getFields(hashes, function(err, options){
			if (err) throw err;

			for (field in options) {
				meta.config[field] = options[field];
			}
			if (typeof _self.softInit == 'function') {
				_self.softInit(callback);
			} else if (typeof callback == 'function'){
				callback();
			}

		});
	};

	Plugin.reload = function(hookVals) {
		var	isThisPlugin = new RegExp(pluginData.id + ':options:' + Object.keys(pluginData.defaults)[0]);
		if (isThisPlugin.test(hookVals.key)) {
			this.init(this.softInit.bind(this));
		}
	};

	Plugin.admin = {
		menu: function(custom_header) {
			custom_header.plugins.push({
				"route": '/plugins/' + pluginData.name,
				"icon": 'icon-edit',
				"name": pluginData.name
			});

			return custom_header;
		},
		route: function(custom_routes, callback) {
			fs.readFile(path.join(__dirname, 'public/templates/admin.tpl'), function(err, tpl) {
				if (err) console.log(err);

				custom_routes.routes.push({
					route: '/plugins/' + pluginData.name,
					method: "get",
					options: function(req, res, callback) {
						callback({
							req: req,
							res: res,
							route: '/plugins/' + pluginData.name,
							name: Plugin,
							content: tpl
						});
					}
				});

				callback(null, custom_routes);
			});
		},
		activate: function(id) {
			log.debug('activate()');
			if (id === pluginData.id) {
				async.each(Object.keys(pluginData.defaults), function(field, next) {
					meta.configs.setOnEmpty(pluginData.id + ':options:' + field, pluginData.defaults[field], next);
				});
			}
		}
	};

	Plugin.softInit = function(callback) {
		log.debug('softInit()');

		var	_self = this;

		if (!meta.config) {
			this.init(callback);
		}

		var prefix = pluginData.id + ':options:';
		Object.keys(meta.config).forEach(function(field, i) {
			var option, value;
			if (field.indexOf(pluginData.id + ':options:') === 0 ) {
				option = field.slice(prefix.length);
				value = meta.config[field];
				_self.config[option] = option == 'navigation' ? JSON.parse(value || pluginData.defaults[option]) : _self.trim(value) || pluginData.defaults[option];
			}
		});
		_self.initialized = true;
		if (typeof callback == 'function') {
			callback();
		}
	};

	Plugin.header = function(custom_header, callback) {
		log.debug('header()');
		var _self = this;

		async.series([
			function(next) {
				if (!_self.initialized) {
					_self.softInit(next);
				} else {
					next();
				}
			},
			function() {
				(_self.config.navigation || []).forEach(function(item) {
					custom_header.navigation.push({
						"route": item.href,
						"text": item.text,
						"title": item.title,
						"class": item.class || '',
						"textClass": item.textClass,
						"iconClass": item.iconClass || ''
					});
				});
				callback(null, custom_header);
			}
		]);
	};

	Plugin.footer = function(custom_footer, callback) {
		log.debug('footer()');
		var _self = this;

		async.series([
			function(next) {
				if (!_self.initialized) {
					_self.softInit(next);
				} else {
					next();
				}
			},
			function() {
				custom_footer = _self.config.footerHtml || '';
				if (_self.config.brandUrl || _self.config.copyright) {
					custom_footer += ''
						+ '\n\n\n\t\t<!-- [' + pluginData.id + '] "much hack, so last minute, so many scared, wow" -doge, 2013-nye -->'
						+ '\n\t\t<script>'
						+ '\n\t\t\t$(function() {'

						+ (_self.config.brandUrl ?
							
							'\n\t\t\t\t$(".navbar-header").find(".forum-logo, .forum-title").each(function(i, el) {'
							+ '\n\t\t\t\t\t\t$(el).parents("a").eq(0).attr("href", "' + _self.config.brandUrl + '");'
							+ '\n\t\t\t\t});' :
							'')

						+ (_self.config.copyright ?
							'\n\t\t\t\t$("footer").find(".copyright").html("' + _self.config.copyright + '");' :
							'')

						+ (_self.config.bodyAppend ?
							'\n\t\t\t\t$("body").append($("' + _self.config.bodyAppend + '"));' :
							'')

						+ '\n\t\t\t});'
						+ '\n\t\t</script>\n\n';
				}

				callback(null, custom_footer);
			}
		]);
	};

	Plugin.trim = function(str){
		return (str || '').replace(/^\s\s*/, '').replace(/\s\s*$/, '');
	};

	Plugin.init();

})(exports);
