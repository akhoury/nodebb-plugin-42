var	fs = require('fs'),
	pluginData = require('./plugin.json'),
	path = require('path'),
	async = require('async'),
	$ = require('cheerio'),
	db = module.parent.require('./database'),
	log = require('tiny-logger').init(process.env.NODE_ENV === 'development' ? 'debug' : 'info,warn,error', '[' + pluginData.id + ']'),
	templates = module.parent.require('./../public/src/templates'),
	meta = module.parent.require('./meta');

(function(Plugin) {
	Plugin.config = {};

	Plugin.util = {
		trim: function(str) {
			return (str || '').replace(/^\s\s*/, '').replace(/\s\s*$/, '');
		},
		isNumber: function (n) {
			return !isNaN(parseFloat(n)) && isFinite(n);
		},
		parseJSON: function(str){
			try {
				return JSON.parse(str);
			} catch (e) {
				return null;
			}
		}
	};

	Plugin.init = function(callback){
		log.debug('init()');
		var _self = this,
			hashes = Object.keys(pluginData.defaults).map(function(field) { return pluginData.id + ':options:' + field });

		meta.configs.getFields(hashes, function(err, options){
			if (err) throw err;

			async.series([
				function(next) {
					db.keys('plugin:config:' + pluginData.id + ':*', function(err, keys) {

						async.each(keys, function(key, next) {
							var shortKey = key.substring('plugin:config:'.length);
							log.debug('loading: ' + key + ' as '+ shortKey);

							db.getObject(key, function(err, val) {
								if (err) {
									log.debug(err + ' -- most likely not an object, benign error, will fix after resolution of: http://community.nodebb.org/topic/486');
								} else {
									log.debug('options setting: ' + shortKey);
									options[shortKey] = val;
								}
								next();
							});
						}, next);
					});
				}],
				function(err){
					if (err) log.error(err);

					for (field in options) {
						meta.config[field] = options[field];
					}
					if (typeof _self.softInit == 'function') {
						_self.softInit(callback);
					} else if (typeof callback == 'function'){
						callback();
					}
				});
		});
	};

	Plugin.reload = function(hookVals) {
		var	isThisPlugin = new RegExp(pluginData.id + ':options:' + Object.keys(pluginData.defaults)[0]);
		if (isThisPlugin.test(hookVals.key)) {
			this.init(this.softInit.bind(this));
		}
	};

	Plugin.admin = {
		saveOptions: function(options, callback) {
			log.debug('saveOptions()');

			async.each(Object.keys(options || {}),

				function(field, next) {
					var value = options[field];
					log.debug('saving: ' + field + ' value: ' + value);
					if (typeof value == 'string') {
						// todo: these save under the global config object
						// http://community.nodebb.org/topic/486/#3573
						meta.configs.set(pluginData.id + ':options:' + field, value, next);
					} else if (Array.isArray(value)) {
						// these don't
						var i = 0, saveValue = function(val, next) {
							db.setObject('plugin:config:' + pluginData.id + ':options:' + field + ':' + i, val, function(err){
								if(err) next(err);
								db.setAdd('plugin:config:' + pluginData.id + ':options:' + field, i, next);
							});
							i++;
						};
						async.each(value, saveValue, next);
					} else if (typeof value == 'object' && !!value) {
						// neither do these
						// wtf redis? can't have nested objects?
						db.setObject('plugin:config:' + pluginData.id + ':options:' + field, value, next);
					}
				},
				callback);
		},
		menu: function(custom_header) {
			custom_header.plugins.push({
				"route": '/plugins/' + pluginData.name,
				"icon": 'fa-edit',
				"name": pluginData.name
			});

			return custom_header;
		},
		route: function(custom_routes, callback) {
			var _self = this;
			fs.readFile(path.join(__dirname, 'public/templates/admin.tpl'), function(err, tpl) {
				if (err) console.log(err);

				custom_routes.routes.push({
					route: '/plugins/' + pluginData.name,
					method: 'get',
					options: function(req, res, callback) {
						callback({
							req: req,
							res: res,
							route: '/plugins/' + pluginData.name,
							name: Plugin,
							content: templates.prepare(tpl.toString()).parse(_self.config || pluginData.defaults)
						});
					}
				});

				custom_routes.api.push({
					route: '/plugins/' + pluginData.name + '/save',
					method: 'post',
					callback: function(req, res, callback) {
						Plugin.admin.saveOptions(req.body.options, function(err) {
							if(err) {
								return res.json(500, {message: err.message});
							}
							Plugin.init(function(){
								callback({message: 'Options saved! If the changes do not reflect immediately on the forum, try restarting NodeBB and clearing your cache.'});
							});
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
		Object.keys(meta.config).forEach(function(field) {
			var option;

			if (field.indexOf(pluginData.id + ':options:') === 0 ) {
				option = field.slice(prefix.length);

				if (option.indexOf(':') > 0) {
					// then it's a set field:i with an index, i.e 'links:0'
					var parts = option.split(':');
					if (!_self.config[parts[0]]) {
						_self.config[parts[0]] = pluginData.defaults[parts[0]];
					}
					_self.config[parts[0]][parts[1]] = meta.config[field];
				} else {
					_self.config[option] = meta.config[field] || pluginData.defaults[option];
				}
			}
		});

		this._generateCustomFooter();
		this.initialized = true;

		if (typeof callback == 'function') {
			callback();
		}
	};

	Plugin._generateCustomFooter = function(){
		var re = /(\r\n|\n|\r)/gm,
			custom_footer = this.config.footerHtml || '';

		if (this.config.brandUrl || this.config.copyright || this.config.headHtml || this.config.bodyAppend) {
			custom_footer += ''
				+ '\n\n\n\t\t<!-- [' + pluginData.id + '] \'much hack, so last minute, so many scared, wow\' -doge, 2013-nye -->'
				+ '\n\t\t<script>'
				+ '\n\t\t\t$(function() {'
				+ (this.config.brandUrl ?
				'\n\t\t\t\t$(\'.navbar-header\').find(\'.forum-logo, .forum-title\').each(function(i, el) {'
					+ '\n\t\t\t\t\t$(el).parents(\'a\').eq(0).attr(\'href\', \'' + this.config.brandUrl + '\');'
					+ '\n\t\t\t\t});' :
				'')
				+ (this.config.copyright ?
				'\n\t\t\t\t$(\'footer\').find(\'.copyright\').html(\'' + $('<p>' + this.config.copyright.replace(re, '') + '</p>').html() + '\');' :
				'')
				+ (this.config.headHtml ?
				'\n\t\t\t\t$(\'head\').append(\'' + $('<p>'  + this.config.headHtml.replace(re, '') + '</p>').html() + '\');' :
				'')
				+ (this.config.bodyAppend ?
				'\n\t\t\t\t$(\'body\').append(\'' + $('<p>' + this.config.bodyAppend.replace(re, '') + '</p>').html() + '\');' :
				'')
				+ '\n\t\t\t});'
				+ '\n\t\t</script>\n\n';
		}
		this._custom_footer = custom_footer;
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
				(_self.config.links || []).forEach(function(item) {
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
				custom_footer += _self._custom_footer || '';
				callback(null, custom_footer);
			}
		]);
	};

	Plugin.init();

})(exports);
