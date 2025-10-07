import 'package:flutter/material.dart';
import 'package:frontend/core/text_style.dart';
import 'package:frontend/screens/camera.dart';
import 'package:frontend/screens/gallery.dart';
import 'package:frontend/screens/map.dart';
import 'package:frontend/screens/trivia.dart';

class HomeButtons extends StatefulWidget {
  const HomeButtons({super.key});

  @override
  State<HomeButtons> createState() => _HomeButtonsState();
}

class _HomeButtonsState extends State<HomeButtons> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Botón Cámara
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              height: 240,
              width: 380,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.lightGreen, Colors.lightBlue],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
              ),
              child: ElevatedButton(
                onPressed: () {
                  //ir a cámara
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraScreen(),
                    ),
                  );
                },
                // estilo del button a cámara
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Figura del botón a cámara
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Icon(
                      Icons.photo_camera_rounded,
                      size: 150,
                      color: const Color.fromARGB(255, 46, 46, 46),
                    ),
                    Text('Identificar Animal', style: TextStyles.buttonTextStyle),
                  ],
                ),
              ),
            ),
          ),

          // separación primer boton de los demás
          const SizedBox(height: 20),

          // botones abajo
          Row(
            children: [
              // Botón galería
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepOrange, Colors.orange],
                      ),
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GalleryScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 198),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Galería',
                            style: TextStyles.buttonTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Botón Mapa
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 18),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ),
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 198),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text('Mapa', style: TextStyles.buttonTextStyle),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          //Botón a trivia
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15, right: 16,left: 4),
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(colors: [Colors.deepOrange, Colors.orange, Colors.deepOrange])
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TriviaScreen() ));
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 100),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8)
                            )
                          ),
                          child: Text('Jugar Trivia',style: TextStyles.buttonTextStyle,),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
