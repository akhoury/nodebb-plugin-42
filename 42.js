var	fs = require('fs-extra'),
	pluginData = require('./plugin.json'),
	path = require('path'),
	db = module.parent.require('./database'),
	winston = module.parent.require('winston'),
	async = module.parent.require('async'),
	templates = module.parent.require('./../public/src/templates'),
	meta = module.parent.require('./meta'),
	debug = process.env.NODE_ENV === 'development',

	Plugin = {

		config: {},

		mem: {},

		util: {

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
					return '';
				}
			},

			escape: function(str){
				return JSON.stringify(str);
			}
		},

		forum: {

			header: function(custom_header, callback) {
				(Plugin.config.links || []).forEach(function(item) {
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
			},

			footer: function(custom_footer, callback) {
				custom_footer += Plugin.config.footerHtml || '';
				callback(null, custom_footer);
			},

			scripts: function(scripts){
				return scripts.concat(

					// concat harcoded files in plugin.json
					(pluginData.js || []).map(function(path) {
						return 'plugins/' + pluginData.id + '/' + path;
					}),

					// also concat this dynamically generated file
					['plugins/' + pluginData.id + '/public/js/dyn/42-' + (Plugin.config.timestamp || 0) + '.js']
				);
			}
		},

		admin: {

			init: function(callback) {
				var prefix = pluginData.id + ':options:',
					eskape = {copyright: 1, headHtml: 1, bodyAppend: 1};

				// normal configs
				Object.keys(meta.config).forEach(function(field){
					var option = '';
					if (field.indexOf(prefix) === 0 ) {
						option = field.slice(prefix.length);
						var val = meta.config[field] || pluginData.defaults[option];
						Plugin.config[option] = eskape[field] ? Plugin.util.escape(val) : val;
					}
				});

				// hashes and sets
				db.keys(pluginData.id + ':options:*', function(err, fields) {
					async.each(fields, function(field, next) {
						db.getObject(field, function(err, val) {
							var option = field.slice(prefix.length);
							if (err) {
								// probable not an object, it's ok
							} else {
								if (option.indexOf(':') > 0) {
									// then it's a set field:i with an index, i.e 'links:0'
									var parts = option.split(':');
									if (!Plugin.config[parts[0]]) {
										Plugin.config[parts[0]] = pluginData.defaults[parts[0]];
									}
									Plugin.config[parts[0]][parts[1]] = val;
								} else {
									Plugin.config[option] = val;
								}
							}
							next();
						});
					}, function(err){
						if (err) winston.error('[' + pluginData.id + ']' + err);

						Plugin.admin._write(function(err){
							if (err) winston.error('[' + pluginData.id + ']' + err);

							if (typeof callback == 'function')
								callback();
						});
					});
				});
			},

			_write: function(callback) {
				var publicPath = path.join(__dirname, 'public');

				fs.readFile(publicPath + '/templates/42.js.tpl', function(err, tpl) {
					if (err) winston.error('[' + pluginData.id + ']' + err);

					var js = templates.prepare(tpl.toString()).parse({pluginData: pluginData, config: Plugin.config || pluginData.defaults});

					fs.remove(publicPath + '/js/dyn', function(err){
						if (err) winston.error('[' + pluginData.id + ']' + err);

						fs.outputFile(path.join(__dirname, 'public/js/dyn/42-' + (Plugin.config.timestamp || 0) + '.js'), js, function(err){
							if (err) winston.error('[' + pluginData.id + ']' + err);
							callback(err);
						});
					});
				});
			},

			menu: function(custom_header) {
				custom_header.plugins.push({
					"route": '/plugins/' + pluginData.name,
					"icon": pluginData['fa-icon'],
					"name": pluginData.name
				});

				return custom_header;
			},

			route: function(custom_routes, callback){
				fs.readFile(path.join(__dirname, 'public/templates/admin.tpl'), function(err, tpl) {
					if (err) winston.error('[' + pluginData.id + ']' + err);

					custom_routes.routes.push({
						route: '/plugins/' + pluginData.name,
						method: 'get',
						options: function(req, res, callback) {
							callback({
								req: req,
								res: res,
								route: '/plugins/' + pluginData.name,
								name: Plugin,
								content: templates.prepare(tpl.toString()).parse(Plugin.config || pluginData.defaults)
							});
						}
					});

					custom_routes.api.push({
						route: '/plugins/' + pluginData.name + '/save',
						method: 'post',
						callback: Plugin.admin.save.bind(Plugin)
					});

					callback(null, custom_routes);
				});
			},

			save: function(req, res, callback) {
				Plugin.admin._save(req.body.options, function(err){
					if(err) {
						return res.json(500, {message: err.message});
					}
					Plugin.admin.init(function(){
						callback({message: 'Options saved! If the changes do not reflect immediately on the forum,'
							+ ' try restarting NodeBB and clearing your cache.'});
					});
				});
			},

			_save: function(options, callback) {
				Plugin.admin._delete(function(err) {
					if (err) winston.error('[' + pluginData.id + ']' + err);

					options.timestamp = +new Date();
					async.each(Object.keys(options || {}),

						function(field, next) {
							var value = options[field];

							if (typeof value == 'string' || Plugin.util.isNumber(value)) {
								meta.configs.set(pluginData.id + ':options:' + field, value, next);
							} else if (Array.isArray(value)) {

								var i = 0,
									saveValue = function(val, next) {
										db.setObject(pluginData.id + ':options:' + field + ':' + i, val, function(err){
											if(err) next(err);
											db.setAdd(pluginData.id + ':options:' + field, i, next);
										});
										i++;
									};
								async.each(value, saveValue, next);

							} else if (typeof value == 'object' && !!value) {
								db.setObject(pluginData.id + ':options:' + field, value, next);
							}
						},
						callback);
				});
			},

			_delete: function(callback){
				db.keys(pluginData.id + ':options:*', function(err, keys) {
					if(err) {
						return callback(err);
					}

					if(!keys || !keys.length) {
						return callback();
					}
					async.each(keys, db.delete, callback);
				});

			}
		}
	};

module.exports = Plugin;
