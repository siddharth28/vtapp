CKEDITOR.editorConfig = function( config )
{
  config.autoParagraph = false;
  config.toolbar =
  [
    { name: 'basicstyles', items : [ 'Bold','Italic','Strike','-','RemoveFormat' ] },
    { name: 'paragraph', items : [ 'NumberedList','BulletedList' ] },
    { name: 'links', items : [ 'Link','Unlink' ] },
  ];
}

