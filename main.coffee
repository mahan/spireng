
#File global references for our sprites.
bunny = null
hunter = null

# By extending (inheriting) from Spireng our class gets access to methods
# for basic drawing operations.
class MyTest1 extends Spireng

  #Override from Spireng. Called before every onRender (i.e. frame).
  #Allows for updating state in the game/application.
  #Timing variables allow for updating state based on true elapsed time
  #regardless of the frame-rate of the target device.
  onUpdate: (deltaTimeMs, totalTimeMs) ->
    #Don't forget to call super() on override.
    super(deltaTimeMs, totalTimeMs)
    @totalTimeMs = totalTimeMs
    @deltaTimeMs = deltaTimeMs

    # We notify the animated sprite about the update so that it can update the
    # images automatically. (This is likely to be handled inside the engine soon)
    hunter.update(deltaTimeMs, totalTimeMs)


  #Override from Spireng.
  #This is where we place things drawn every frame.
  onRender: ->
    # Don't forget super() on override
    super()

    #Check that initial color is visible
    @setLineWidth(20)
    @plot(300, 10)
    @setLineWidth(1)


    #Color for every draw operation (rect, line, text etc.)
    #Once you set this, it's assumed for all draw operations that follow during the life of onRender()
    @setColor("White")
    @text("totalTimeMs: #{@totalTimeMs}", 50, 10)

    @setColor("#A0A0A0")
    @text("deltaTimeMs: #{@deltaTimeMs}", 150, 10)


    @setColor('#8080A0')

    #The functions @width() and @height() return the size of the screen.
    #They are automatically updated if the screen would happen to resize at any time.
    #(This happens if the user resizes the browser window, or if the orientation of a device changes)
    @line(0, 0, @width(), @height())

    @setColor('#008000')
    @circle(100, 60, 50)


    #Plotting some sinus'ish curve that changes over time.
    @setColor("Blue")
    for x in [0..@width()] by 10
      xOffset = ((@totalTimeMs + x) % 40 + (@totalTimeMs % 5))
      @plot(x, (@height()/2) + (Math.sin((x+xOffset)/50)*100))

    #A box is made to move over the screen by making it relative to the time (in milliseconds) since the game started.
    @setColor('#505050')
    xPos = @totalTimeMs % @width()
    @rect(xPos, 100, 10, 10)

    @setColor("Blue")
    #Note that shapes can be filled with a color. If we want to draw unfilled shapes afterwards we can use @clearFillColor()
    @setFillColor("Yellow")
    #We can draw with broader strokes:
    @setLineWidth(10)
    @rect(300, 300, 50, 50)

    #Bunny is rendered twice. Once normally and then another time rotated.
    #The rotation changes over time.
    bunny.x = @width() / 2
    bunny.y = @height() / 2
    bunny.angle = 0
    bunny.render(@ctx) #First render. Original angle.
    bunny.angle = @totalTimeMs / 36
    bunny.render(@ctx) #Second render. Moving angle.

    #Our animated char is rendered to the screen
    hunter.x = @width() / 2 +100
    hunter.y = @height() / 2
    hunter.render(@ctx)


# main get's called right after resources are loaded (see below)
main = ->

  # We start two sprites for our demo. The second one is animated from a sprite sheet
  bunny = new Spireng.Sprite(Spireng.resources.get("bunny.png"), 500, 500)
  AnimatedSprite = Spireng.AnimatedSprite
  hunter = new AnimatedSprite(Spireng.resources.get("hunter_looking_sw.png"), 96, 96, 12, AnimatedSprite.FORWARD, 100)

  #By instanciating our (Spireng based) class we start up the show.
  myTest = new MyTest1()
  myTest.setClsColor("black") #This is if you want to clear the screen with a specific color before each frame.


# This is the starting point of the program.
# We specify the resources (images) we want loaded before the game starts.
Spireng.resources.load(["bunny.png", "hunter_looking_sw.png"]).addReadyListener(main)
