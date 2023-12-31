void MapInit()
{
    CYCLERMODEL::EntityRegister();
}

namespace CYCLERMODEL
{

enum CyclerState
{
    MDL_1 = 0,
    MDL_2
};

final class cyclermdl : ScriptBaseAnimating
{
    // Config
    private string m_szModel1, m_szModel2;
    private int m_iSeq1, m_iSeq2;
    private float m_flFrameRate;
    private Vector m_Controller;

    bool KeyValue(const string& in szKey, const string& in szValue)
    {
        if( szKey == "_mdl0" )
            m_szModel1 = szValue;
        else if( szKey == "_mdl1")
            m_szModel2 = szValue;
        else if( szKey == "_seq0" )
            m_iSeq1 = atoi( szValue );
        else if( szKey == "_seq1" )
            m_iSeq2 = atoi( szValue );
        else if( szKey == "controller" )
            g_Utility.StringToVector( m_Controller, szValue );
        else
            return BaseClass.KeyValue( szKey, szValue );

        return true;
    }

    // Precache the models
    void Precache()
    {
        g_Game.PrecacheModel( m_szModel1 ); 
        g_Game.PrecacheModel( m_szModel2 ); 

        BaseClass.Precache();
    }

    // Spawn the entity
    void Spawn( )
    {
        self.Precache();
        
        // Model
        g_EntityFuncs.SetModel( self, m_szModel1 );

        // Physics
        self.pev.solid      = SOLID_SLIDEBOX;
        self.pev.movetype   = MOVETYPE_NONE;
        self.pev.takedamage	= DAMAGE_NO;

        self.pev.sequence = m_iSeq1;
        self.ResetSequenceInfo();
        self.pev.frame = 0;

        // Size & origin
        g_EntityFuncs.SetSize( self.pev, Vector( -16, -16, 0 ), Vector( 16, 16, 16 ) );
        g_EntityFuncs.SetOrigin( self, self.pev.origin );

        // Controller
        self.pev.set_controller( 0, int(m_Controller.y) );
        self.pev.set_controller( 1, int(m_Controller.x) );
        self.pev.set_controller( 2, int(m_Controller.z) );

        // Current state
        self.pev.iuser1 = MDL_1;

        // Spawn
        BaseClass.Spawn();
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
    {
        // Filter by entity called state
        switch( self.pev.iuser1 )
        {
            case MDL_1:
            {
                if(string(self.pev.model) != m_szModel2)
                {
                    g_EntityFuncs.SetModel( self, m_szModel2 );
                    g_EntityFuncs.SetSize( self.pev, Vector( -16, -16, 0 ), Vector( 16, 16, 16 ) );
                    g_EntityFuncs.SetOrigin( self, self.pev.origin );
                }

                self.pev.sequence = m_iSeq2;
                self.ResetSequenceInfo();

                // Next Statew
                self.pev.iuser1 = MDL_2;
                break;
            }
            case MDL_2:
            {   
                if(string(self.pev.model) != m_szModel1)
                {
                    g_EntityFuncs.SetModel( self, m_szModel1 );
                    g_EntityFuncs.SetSize( self.pev, Vector( -16, -16, 0 ), Vector( 16, 16, 16 ) );
                    g_EntityFuncs.SetOrigin( self, self.pev.origin );
                }
                
                self.pev.sequence = m_iSeq1;
                self.ResetSequenceInfo();

                // Next State
                self.pev.iuser1 = MDL_1;
                break;
            }
        }
    }
}

// Register
bool EntityRegister()
{
    g_CustomEntityFuncs.RegisterCustomEntity( "CYCLERMODEL::cyclermdl", "cycler_mdl" );
    return g_CustomEntityFuncs.IsCustomEntity( "cycler_mdl" );
}

} // End
