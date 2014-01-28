// {pluginData.id} : {config.timestamp}
// 'much hack, so last minute, so many scared, wow' -doge
// generated JavaScript, do not replace, it will resurrect

$(function(){
    <!-- IF config.brandUrl -->
		$('.navbar-header')
			.find('.forum-logo, .forum-title')
				.each(function(i, el) {
					$(el).parents('a').eq(0).attr('href', '{config.brandUrl}');
				});
	<-- ENDIF config.brandUrl -->

	<!-- IF config.copyright -->
		$('footer').find('.copyright').html($({config.copyright}));
	<-- ENDIF config.copyright -->

	<!-- IF config.headHtml -->
		$('head').append($({config.headHtml}));
	<-- ENDIF config.headHtml -->

	<!-- IF config.bodyAppend -->
		$('body').append($({config.bodyAppend}));
	<-- ENDIF config.bodyAppend -->
});