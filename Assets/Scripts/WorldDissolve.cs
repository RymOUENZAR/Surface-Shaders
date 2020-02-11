using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldDissolve : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //Updates the _PlayerPos variable in all the shaders
        //Be aware that the parameter name has to match the one in your shaders or it wont' work
        Shader.SetGlobalVector("_PlayerPos", transform.position); //"transform" is the transform of the Player
    }
}
