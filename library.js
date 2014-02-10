var	fs = require('fs-extra'),
	pluginData = require('./plugin.json'),
	path = require('path'),
	db = module.parent.require('./database'),
	winston = module.parent.require('winston'),
	async = module.parent.require('async'),
	templates = module.parent.require('./../public/src/templates'),
	utils = module.parent.require('./../public/src/utils'),
	meta = module.parent.require('./meta'),
	debug = process.env.NODE_ENV === 'development',

	Plugin = {

		config: {},

		util: {
			trimSpaces: function(str) {
				return (str || '').replace(/^\s\s*/, '').replace(/\s\s*$/, '');
			},
			trimNewlines: function(str) {
				return (str || '').replace(/(\r\n|\n|\r)/gm, '');
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
                var footer = function(){
                    custom_footer += Plugin.config.footerHtml || '';
                    callback(null, custom_footer);
                };

                if (this.initialized) {
                    footer();
                } else {
                    this.admin.init(null, footer);
                }
			},

			scripts: function(scripts){
				return scripts.concat(

					// concat harcoded files in plugin.json, if there is any
					(pluginData.js || []).map(function(path) {
						return 'plugins/' + pluginData.id + '/' + path;
					}),

					// also concat this dynamicamically generated sfile
					['plugins/' + pluginData.id + '/js/dynamic/42.js']
				);
			}
		},

		admin: {
			init: function(app, callback) {
				if (debug) winston.info('[' + pluginData.id + '] initializing');
				fs.readJson(path.join(__dirname, '/config.json'), function(err, config){
					if (err) { 
						winston.error('[' + pluginData.id + ']' + err);
						config = {};
					}
					Plugin.config = utils.merge({}, pluginData.defaults, config);

					Plugin.admin._write(function(err) {
						if (err) {
                            winston.error('[' + pluginData.id + ']' + err);
                        } else {
                            Plugin.initialized = true;
                        }
						if (typeof callback == 'function')
							callback();
					});
				});
			},

			_write: function(callback) {
				var publicPath = path.join(__dirname, 'public');

				fs.readFile(publicPath + '/templates/42.js.tpl', function(err, tpl) {
					if (err) winston.error('[' + pluginData.id + ']' + err);

					// trim new lines
					// todo: clean this shit
					var data = {pluginData: pluginData, config: Plugin.config};
					data.config = (function(keys){
						var config = {};
						keys.forEach(function(key) {
							if (data.config[key].replace)
								config[key] = Plugin.util.trimNewlines(data.config[key]);
							else
								config[key] = data.config[key];
						});
						return config;
					})(Object.keys(data.config));

					var js = templates.prepare(tpl.toString()).parse(data);

					fs.remove(publicPath + '/js/dynamic', function(err){
						if (err) winston.error('[' + pluginData.id + ']' + err);

						fs.outputFile(path.join(__dirname, 'public/js/dynamic/42.js'), js, function(err){
							if (err) winston.error('[' + pluginData.id + ']' + err);

							if (debug)
								winston.info('[' + pluginData.id + '] javascript file: ' + path.join(__dirname, 'public/js/dynamic/42.js') + ' written');

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
								content: templates.prepare(tpl.toString()).parse(Plugin.config)
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
				var options = req.body.options;

				options.timestamp = +new Date();
				fs.outputJson(path.join(__dirname, '/config.json'), utils.merge({}, pluginData.defaults, options), function(err){
					if(err) {
						return res.json(500, {message: err.message});
					}
					Plugin.admin.init(null, function() {
						callback({message: 'Options saved! If the changes do not reflect immediately on the forum,'
							+ ' try restarting NodeBB and clearing your cache.'});
					});
				});
			}
		}
	};

module.exports = Plugin;
