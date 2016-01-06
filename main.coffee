
bunny = null
hunter = null

class MyTest1 extends Spireng

  onUpdate: (deltaTimeMs, totalTimeMs) ->
    super(deltaTimeMs, totalTimeMs)
    @totalTimeMs = totalTimeMs
    @deltaTimeMs = deltaTimeMs
    #console.log "deltaTimeMs: #{deltaTimeMs} totalTimeMs: #{totalTimeMs}"

    hunter.update(deltaTimeMs, totalTimeMs)


  onRender: ->
    super()

    @setColor("White")
    @text("totalTimeMs: #{@totalTimeMs}", 50, 10)

    @setColor("#A0A0A0")
    @text("totalTimeMs: #{@deltaTimeMs}", 150, 10)


    @setColor('#8080A0')

    @line(0, 0, @width(), @height())

    @setColor('#008000')
    @circle(100, 60, 50)


    @setColor("Blue")
    for x in [0..@width()] by 10
      xOffset = ((@totalTimeMs + x) % 40 + (@totalTimeMs % 5))
      @plot(x, (@height()/2) + (Math.sin((x+xOffset)/50)*100))


    @setColor('#505050')
    xPos = @totalTimeMs % @width()
    @rect(xPos, 100, 10, 10)

    @setColor("Blue")
    @setFillColor("Yellow")
    @setLineWidth(10)
    @rect(300, 300, 50, 50)

    bunny.x = @width() / 2
    bunny.y = @height() / 2

    bunny.angle = 0

    bunny.render(@ctx)

    bunny.angle = @totalTimeMs / 36

    bunny.render(@ctx)

    hunter.x = @width() / 2 +100
    hunter.y = @height() / 2
    #hunter.angle = @totalTimeMs / 10

    hunter.render(@ctx)
    #hunter.previousImage()


main = ->

  bunny = new Spireng.Sprite(Spireng.resources.get("bunny.png"), 500, 500)

  #hunter = new Spireng.SheetSprite(Spireng.resources.get("looking_se.png"), 96, 96, 13)

  AnimatedSprite = Spireng.AnimatedSprite


  #constructor: (@resource, @width, @height, @numberOfImages, @animType, @animFrameMs, @x=0, @y=0, @angle=0) ->
  hunter = new AnimatedSprite(Spireng.resources.get("hunter_looking_sw.png"), 96, 96, 12, AnimatedSprite.FORWARD, 100)


  myTest = new MyTest1()
  myTest.setClsColor("Black")



Spireng.resources.load(["bunny.png", "hunter_looking_sw.png"]).addReadyListener(main)
#main()
