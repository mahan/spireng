


class Resources

  constructor: ->
    @resourceCache = {}
    @readyCallbacks = []

  # Load an image url or an array of image urls
  load: (urlOrArr) ->
    if (urlOrArr instanceof Array)
      urlOrArr.forEach (url) =>
        @_load(url)
    else
      @_load(urlOrArr)
    return @

  _load: (url) ->
    if @resourceCache[url]?
      return @resourceCache[url]
    else
      img = new Image()
      img.onload =  =>
        @resourceCache[url] = img

        if @isReady()
          (func() for func in @readyCallbacks)
          @readyCallbacks = []
      @resourceCache[url] = false;
      img.src = url

  get: (url) ->
    return @resourceCache[url]

  isReady: ->
    return ((_ for own _, v of @resourceCache when not v).length == 0)

  addReadyListener: (func) ->
    @readyCallbacks.push(func)


# The SpirengBase class provides basic canvas drawing etc.
# Can be used with any canvas, i.e even offscreen
class SpirengBase

  constructor: (canvasElement) ->
    @canvas = canvasElement
    @ctx = @canvas.getContext("2d")
    @color = 'Black'
    @fillColor = null
    @ctx.strokeStyle = @color
    @ctx.fillStyle = "rgba(0, 0, 0, 0)" #set transparent fillStyle default

  width: ->
    @canvas.width

  height: ->
    @canvas.height

  #Color such as '#808080'
  setColor: (color) ->
    @color = color
    @ctx.strokeStyle = @color

  #Color such as '#808080'
  setFillColor: (fillColor) ->
    @fillColor = fillColor
    unless @fillColor?
      @ctx.fillStyle = "rgba(0, 0, 0, 0)" #set transparent
    else
      @ctx.fillStyle = @fillColor

  clearFillColor: ->
    @setFillColor()

  setLineWidth: (lineWidthPx) ->
    @ctx.lineWidth = lineWidthPx

  line: (x1, y1, x2, y2) ->
    @ctx.beginPath()
    @ctx.moveTo(x1,y1)
    @ctx.lineTo(x2, y2)
    @ctx.stroke()

  rect: (x, y, w, h) ->
    @ctx.beginPath()
    @ctx.rect(x, y, w, h)
    if @fillColor?
      @ctx.fill()
    @ctx.stroke()

  circle: (x, y, r) ->
    @ctx.beginPath()
    @ctx.arc(x, y, r, 0, 2 * Math.PI, false)
    if @fillColor?
      @ctx.fill()
    @ctx.stroke()

  plot: (x, y) ->
    @rect(x, y, 1, 1)

  text: (text, x, y) ->
    @ctx.fillStyle = @color
    @ctx.fillText(text, x, y)
    @setFillColor(@fillColor)

# This is the screen renderer class that draws on the visible canvas
# privodes timing and drawing hook (mainloop)
class SpirengRenderer extends SpirengBase

  constructor: ->
    document.body.style.margin = "0px 0px 0px 0px";
    @canvas = document.createElement("canvas")
    super(@canvas)
    document.body.appendChild(@canvas);
    window.addEventListener 'resize', =>
      @onResize()
    @onResize()


    @startTime = Date.now()
    @clsColor = null
    requestAnimationFrame =>
      @mainLoop()


  setClsColor: (clsColor) ->
    @clsColor = clsColor

  # Override and don't forget to call super()
  onResize: ->
    fillStyleBefore = @ctx.fillStyle #Somehow fillstyle gets set to black on canvas resize (safari)
    @canvas.width = document.documentElement.clientWidth #window.innerWidth
    @canvas.height = document.documentElement.clientHeight #window.innerHeight
    @ctx.fillStyle = fillStyleBefore

  mainLoop: ->
    now = Date.now()
    unless @lastMainLoopTime?
      @lastMainLoopTime = Date.now()

    dt = (now - @lastMainLoopTime)
    if dt == 0 then dt = 1  #try do spare users of div-by-zero
    t = (now - @startTime)

    #console.log dt

    @onUpdate(dt, t)
    if @clsColor?
      @setFillColor(@clsColor)
      @setColor(@clsColor)
      @ctx.fillStyle = @clsColor
      @ctx.fillRect(0, 0, @width(), @height())
      @setColor()
    else
      @ctx.clearRect(0, 0, @width(), @height())
    @setColor("#808080") #Set gray as default color.
    @clearFillColor()
    @setLineWidth(1)
    @onRender()

    @lastMainLoopTime = now
    requestAnimationFrame =>
      @mainLoop()

  #Override!
  onUpdate: (deltaTimeMs, totalTimeMs) ->

  #Override!
  onRender: ->


class Sprite

  #Angle in degrees
  constructor: (@resource, @x=0, @y=0, @angle=0) ->

  update: ->
    #Basic sprites do not need updating.

  render: (ctx) ->
    @angle = (@angle % 360)
    if @angle == 0
      ctx.drawImage(@resource, @x, @y)
    else
      angleInRadians = @angle  * (Math.PI/180)
      xTrans = @x + (@resource.width / 2)
      yTrans = @y + (@resource.height / 2)
      ctx.translate(xTrans, yTrans)
      ctx.rotate(angleInRadians)
      ctx.drawImage(@resource, -(@resource.width) / 2, -(@resource.height) / 2, @resource.width, @resource.height);
      #ctx.drawImage(@resource, 0, 0);
      ctx.rotate(-angleInRadians);
      ctx.translate(-xTrans, -yTrans);


#A SheetSprite is a sprite based of a sprite sheet (multiple images in an Image)
class SheetSprite

  constructor: (@resource, @width, @height, @numberOfImages, @x=0, @y=0, @angle=0) ->
    @imageNo = 0
    @imageCoords = @calculateImageCoords()

  calculateImageCoords: ->
    r = []
    w = @resource.width
    h = @resource.height

    #sanity check
    if (w < @width) or (h < @height)
      throw "SheetSprite resource smaller than sprite dimensions"

    c = 0
    x = 0
    y = 0
    while c < @numberOfImages
      c++
      coords = {
        x
        y
      }
      r.push coords
      x += @width
      if x >= w
        y += @height
        x = 0
      if (c < @numberOfImages) and (y+@height > h)
        throw "SheetSprite @numberOfImages exceed resource"
      #c++
    return r

  render: (ctx) ->
    @angle = (@angle % 360)
    if @angle == 0
      ctx.drawImage(@resource, @imageCoords[@imageNo].x, @imageCoords[@imageNo].y, @width, @height, @x, @y, @width, @height)
    else
      angleInRadians = @angle  * (Math.PI/180)
      xTrans = @x + (@width / 2)
      yTrans = @y + (@height / 2)
      ctx.translate(xTrans, yTrans)
      ctx.rotate(angleInRadians)
      ctx.drawImage(@resource, @imageCoords[@imageNo].x, @imageCoords[@imageNo].y, @width, @height, -@width / 2, -@height / 2, @width, @height);
      #ctx.drawImage(@resource, 0, 0);
      ctx.rotate(-angleInRadians);
      ctx.translate(-xTrans, -yTrans);

  setImage: (imageNo) ->
    if imageNo >= @numberOfImages
      imageNo = @numberOfImages -1
    if imageNo < 0
      imageNo = 0
    @imageNo = imageNo

  isFirstImage: ->
    return (@imageNo == 0)

  isLastImage: ->
    return (@imageNo == @numberOfImages-1)

  nextImage: ->
    if @isLastImage()
      @firstImage()
    else
      @setImage(++@imageNo)

  #Stop if at last image
  nextImageStop: ->
    if @isLastImage()
      return
    else
      @setImage(++@imageNo)

  previousImage: ->
    if @isFirstImage()
      @lastImage()
    else
      @setImage(--@imageNo)

  #Stop if at first image
  previousImageStop: ->
    if @isFirstImage()
      return
    else
      @setImage(--@imageNo)


  firstImage: ->
    @setImage(0)

  lastImage: ->
    @setImage(@numberOfImages-1)


class AnimatedSprite extends SheetSprite

  @PING_PONG     = 1
  @FORWARD       = 2
  @BACKWARD      = 3
  @FORWARD_ONCE  = 4
  @BACKWARD_ONCE = 5

  constructor: (@resource, @width, @height, @numberOfImages, @animType, @animFrameMs, @x=0, @y=0, @angle=0) ->
    super(@resource, @width, @height, @numberOfImages, @x, @y, @angle)
    @lastFrameUpdateMs = 0
    @pingPongForward = true #special variable for pingpong

    if @animType in [AnimatedSprite.BACKWARD, AnimatedSprite.BACKWARD_ONCE]
      @lastImage()

  update: (deltaTimeMs, totalTimeMs) ->
    #console.log("update(totalTimeMs=#{totalTimeMs})")
    if @lastFrameUpdateMs == 0
      @lastFrameUpdateMs = totalTimeMs
      return
    if (@lastFrameUpdateMs + @animFrameMs) < totalTimeMs
      @lastFrameUpdateMs = totalTimeMs - (totalTimeMs - (@lastFrameUpdateMs + @animFrameMs))
      switch @animType
        when AnimatedSprite.FORWARD
          @nextImage()
        when AnimatedSprite.FORWARD_ONCE
          @nextImageStop()
        when AnimatedSprite.BACKWARD
          @previousImage()
        when AnimatedSprite.BACKWARD_ONCE
          @previousImageStop()
        when AnimatedSprite.PING_PONG
          if @pingPongForward
            if @isLastImage()
              @pingPongForward = false
              @previousImage()
            else
              @nextImage()
          else #@pingPongForward == false
            if @isFirstImage()
              @pingPongForward = true
              @nextImage()
            else
              @previousImage()


# A sprite layer is basically a container for sprites that can be drawn together
# The "layer" part is when using several containers in unison and drawing them
# at a certain order ensures the "z-order" on the screen.
# (Imagine layers like "ground", "players" etc. players should probably ALWAYS
#  be drawn AFTER the ground they are supposedly standing on)
class SpriteLayer

  constructor: (@x = 0, @y = 0) ->
    @sprites = []

  addSprite: (sprite) ->
    @sprites.push(sprite)

  removeSprite: (sprite) ->
    @sprites = (s for s in @sprites when s isnt sprite)

  clear: ->
    @sprites = []

  update: (deltaTimeMs, totalTimeMs) ->
    for sprite in @sprites
      sprite.update(deltaTimeMs, totalTimeMs)

  render: (ctx) ->
    ctx.translate(@x, @y)
    for sprite in @sprites
      sprite.render(ctx)
    ctx.translate(-@x, -@y)



###
  Main class for Spireng
###
class Spireng extends SpirengRenderer

  constructor: ->
    super()
    @spriteLayers = []

  #Accessors allows users of this library to access all internal classes
  @SpirengBase: SpirengBase
  @SpirengRenderer: SpirengRenderer
  @Resources: Resources
  @Sprite: Sprite
  @SheetSprite: SheetSprite
  @AnimatedSprite: AnimatedSprite
  @SpriteLayer: SpriteLayer

  #resources singleton for convenience
  @resources = new Resources()

  onUpdate: (deltaTimeMs, totalTimeMs) ->
    super(deltaTimeMs, totalTimeMs)
    for layer in @spriteLayers
      layer.update(deltaTimeMs, totalTimeMs)

  onRender: ->
    super()
    for layer in @spriteLayers
      layer.render(@ctx)


  addSpriteLayer: (spriteLayer) ->
    @spriteLayers.push spriteLayer

  removeSpriteLayer: (spriteLayer) ->
    @spriteLayers = (l for l in @spriteLayers when l isnt spriteLayer)

  clearSpriteLayers: ->
    @spriteLayers = []


if module?.exports?
  module.exports = Spireng
else
  window.Spireng = Spireng
