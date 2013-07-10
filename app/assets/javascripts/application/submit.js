$(document).ready(function() {
  var $mobile = false;

  (function() {
    if(/Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent)) {
      $mobile = true;
    }
  })();

  handle_text_change = function(field) {
    var elm;

    $('#' + field).data('val', $('#' + field).val());
    $('#' + field).change(function() {
      $('#' + elm + ' .yours').text($(this).val());
    });

    $('#' + field).keyup(function() {
      elm = $('#post_meme_position').val() + '_text';
      if ($('#' + field).val() !== $('#' + field).data('val')) {
        $('#' + field).data('val', $('#' + field).val());
        if ($('#' + field).val() !== "") {
          $('#' + elm).show().css('visibility', 'visible');
        }
        else {
          $('.text-pos').hide();
        }

        $(this).change();
      }
    });
  };

  $('#post_meme_position').change(function() {
    var e = $(this).val();
    var val = $('#post_meme_text').val();

    $('.text-pos').hide();
    $('#' + e + '_text').find('.yours').text(val);
    if (val !== "") {
      $('#' + e + '_text').show().css('visibility', 'visible');
    }
  });

  //crop upload helpers

  //removes the overlay and popup
  remove_crop = function(e) {
    if(e)
      e.preventDefault();
    $("#crop-container").remove();
    $("#crop-overlay").remove();
    $("body").off("keydown");
    $(window).off("resize");
  };

  //resets the image field to nothing
  reset_img = function(e) {
    e.preventDefault();
    $("#post_image").wrap('<form>').closest('form').get(0).reset();
    $("#post_image").unwrap();
    $('#upload-preview span.text').show();
    $('#upload-preview').removeClass('loading');
    remove_crop();
  };

  //modal crop popup
  crop_upload = function(filename) {
    //append necessary html and style
    var overlay = $("<div></div>");
    overlay.attr("id", "crop-overlay");
    overlay.appendTo("body");
    var container = $("<div></div>");
    container.attr("id", "crop-container");
    container.appendTo("body");
    var header = $('<h2>Squarify your image!</h2>');
    header.appendTo("#crop-container");
    var img_container = $("<div></div>");
    img_container.attr("id", "crop-img-container");
    img_container.appendTo("#crop-container");
    var img = $('<img />');
    img.attr('src', '/system/tmp/' + filename);
    img.appendTo('#crop-img-container');
    //hide until image is loaded and positioned
    overlay.css("display", "hidden");
    container.css("display", "hidden");
    img.hide();
    img.load(function() {
      //scale image to always fit in the window
      img.css({
        height: ($(window).height() - header.height() - $("#crop-button").height() - 125) + "px",
        width: "auto"
      });
      if(img.width() > $(window).width() - 120)
        img.css({
          width: ($(window).width() - 120) + "px",
          height: "auto"
      });
      //show once everything is loaded
      img.show();
      overlay.css("display", "block");
      container.css("display", "block");
      //set the crop_dim_w used to calculate the ratio to crop correctly with paperclip
      $("#crop_dim_w").val(img.width());
      var cropbox_dim = img.width() > img.height() ? img.height() : img.width();

      //updates hidden fields so paperclip knows what part to crop
      update_crop = function(coords) {
        $("#crop_x").val(coords.x);
        $("#crop_y").val(coords.y);
        $("#crop_w").val(coords.w);
        $("#crop_h").val(coords.h);
      }

      //initialize jcrop
      var jcrop_api;
      img.Jcrop({
        onChange: update_crop,
        onSelect: update_crop,
        setSelect: [0, 0, cropbox_dim, cropbox_dim],
        aspectRatio: 1
      }, function() {
        jcrop_api = this;
      });

      //responsive for crop popup
      $(window).resize(function() {
        var old_width = img.width();
        var old_x = $("#crop_x").val();
        var old_y = $("#crop_y").val();
        var old_w = $("#crop_w").val();
        var old_h = $("#crop_h").val();
        jcrop_api.destroy();
        img.css({
          height: ($(window).height() - header.height() - $("#crop-button").height() - 125) + "px",
          width: "auto"
        });
        if(img.width() > $(window).width() - 120)
          img.css({
            width: ($(window).width() - 120) + "px",
            height: "auto"
          });
        $("#crop_dim_w").val(img.width());
        var ratio = img.width() / old_width;
        var new_x = Math.round(old_x * ratio);
        var new_y = Math.round(old_y * ratio);
        var new_w = Math.round(old_w * ratio);
        var new_h = Math.round(old_h * ratio);
        img.Jcrop({
          onChange: update_crop,
          onSelect: update_crop,
          setSelect: [new_x, new_y, new_x + new_w, new_y + new_h],
          aspectRatio: 1
        }, function() {
          jcrop_api = this;
        });
      });
    });
    var crop_button = $("<a href='#' class='btn primary'>Crop</a>");
    crop_button.attr("id", "crop-button");
    crop_button.appendTo('#crop-container');
    var cancel_button = $("<a href='#' class='btn secondary'>Cancel</a>");
    cancel_button.attr("id", "cancel-button");
    cancel_button.appendTo('#crop-container');

    //add appropriate handlers for buttons
    crop_button.click(function(e) {
      remove_crop(e);
      change_upload(filename, img.width(), img.height());
    });
    cancel_button.click(function(e) {
      reset_img(e);
    });
    overlay.click(function(e) {
      reset_img(e);
    });
    $("body").keydown(function(e) {
      if((e.which) == 27)
        reset_img(e);
    });
  };

  //load the upload preview image
  change_upload = function(filename, width, height) {
    $('#upload-box').find('span').hide();
    var preview_size = $("#upload-preview").width();
    var img_container = $("<div></div>")
    img_container.attr("id", "preview-img-container");
    img_container.css({
      width: $("#crop_w").val(),
      height: $("#crop_h").val(),
      transform: "scale(" + (preview_size / $("#crop_w").val()) +")",
      marginLeft: (Math.round(preview_size / 2) - $("#crop_w").val() / 2) + "px",
      marginTop: (Math.round(preview_size / 2) - $("#crop_h").val() / 2) + "px"
    });
    img_container.appendTo('#upload-preview');

    //responsive for upload preview image
    $(window).resize(function() {
      preview_size = $("#upload-preview").width();
      img_container.css({
        width: $("#crop_w").val(),
        height: $("#crop_h").val(),
        transform: "scale(" + (preview_size / $("#crop_w").val()) +")",
        marginLeft: (Math.round(preview_size / 2) - $("#crop_w").val() / 2) + "px",
        marginTop: (Math.round(preview_size / 2) - $("#crop_h").val() / 2) + "px"
      });
    });
    maintain_ratio('#upload-preview');

    var img = $('<img />');
    img.attr('src', '/system/tmp/' + filename);
    img.css({
      width: width + "px",
      height: height + "px",
      marginLeft: "-" + $("#crop_x").val() + "px",
      marginTop: "-" + $("#crop_y").val() + "px"
    });
    img.appendTo('#preview-img-container');
    img.load(function () {
      $('#upload-preview span').hide();
      $('#upload-preview').removeClass('loading');
    });

    handle_text_change('post_meme_text');

    $('.form-item-meme-text, .form-item-meme-position').show();
  };

  //respond when someone picks a new image
  $('#post_image').change(function() {
    $('#post_meme_text').val("");
    $(".text-pos").hide();
    $("#preview-img-container").remove();

    //make sure we don't try to crop a nonexistent photo
    if ($(this).val() !== "") {
      var file_data = $("#post_image").prop("files")[0];
      if (!file_data.type.match(/image\/(jpeg|gif|png)/)) {
        $('#image_error').show();
        return false;
      }

      $('#upload-preview span.text').hide();
      $('#upload-preview').addClass('loading');

      $('#upload-preview span').hide();
      $('#upload-preview').addClass('loading');
      var form_data = new FormData();
      form_data.append("file", file_data);
      $.ajax({
        url: "/autoimg",
        dataType: 'script',
        cache: false,
        contentType: false,
        processData: false,
        data: form_data,
        type: 'post',
        complete: function(response) {
          res = $.parseJSON(response.responseText);
          if (res.success === true) {
            //if (!$mobile) {
              crop_upload(res.filename);
            //}
            //else {
            //  change_upload(res.filename, 450, 450);
            //}
          }
          else {
            $('#image_error').text(res.reason).show();
          }
        }
      });
    }
    else {
      $('#form-item-meme-text, #form-item-meme-position, #top_text, #bottom_text').hide();
      $('#upload-preview img').remove();
      $('#upload-preview span.text').show();
      $('#upload-preview').removeClass('loading');
    }
  });
});
