using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetShaderProperty : MonoBehaviour
{
    public Material mat;
    public string propertyName;
    public Transform player;

    void Update()
    {
        if (player != null)
            mat.SetVector(propertyName, player.position);
        else
            Debug.Log("Assign the player property");
    }
}
