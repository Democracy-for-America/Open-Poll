$('a.social').click(function(){
    var width = window.innerWidth;
    var left = (width - 574)/2;
    return !window.open(this.href, '_blank', 'height=436, width=574, top=100, left=' + left);
});