// plugin: {pluginData.id}
// timestamp: {config.timestamp}
// note: generated JavaScript, do not replace, it will resurrect

// if there is a syntax error in the generated javascript
// try escaping your single quotes from: ' to: \' - or just use double quotes " instead


$(function(){
    var wrap = document.createElement('div');

    <!-- IF config.brandUrl -->
	$('.navbar-header').find('.forum-logo, .forum-title').each(function(i, el) {$(el).parents('a').eq(0).attr('href', '{config.brandUrl}');});
	<!-- ENDIF config.brandUrl -->
	<!-- IF config.copyright -->
	wrap.innerHTML = '{config.copyright}';
	$('footer').find('.copyright').html(wrap.innerHTML);
	<!-- ENDIF config.copyright -->
	<!-- IF config.headHtml -->
	wrap.innerHTML = '{config.headHtml}';
	$('head')[0].appendChild(wrap);
	<!-- ENDIF config.headHtml -->
	<!-- IF config.bodyAppend -->
	wrap.innerHTML = '{config.bodyAppend}';
	$('body')[0].appendChild(wrap);
	<!-- ENDIF config.bodyAppend -->
	wrap.innerHTML = '';
});