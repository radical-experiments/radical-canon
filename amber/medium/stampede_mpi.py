#!/usr/bin/env python

__copyright__ = "Copyright 2013-2014, http://radical.rutgers.edu"
__license__   = "MIT"

import os
import sys
import radical.pilot as rp

#------------------------------------------------------------------------------
#
def pilot_state_cb (pilot, state):
    """ this callback is invoked on all pilot state changes """

    print "[Callback]: ComputePilot '%s' state: %s." % (pilot.uid, state)

    if state == rp.FAILED:
        sys.exit (1)

    if state in [rp.DONE, rp.FAILED, rp.CANCELED]:
        for cb in pilot.callback_history:
            print cb

#------------------------------------------------------------------------------
#
def unit_state_cb (unit, state):
    """ this callback is invoked on all unit state changes """

    print "[Callback]: ComputeUnit  '%s: %s' (on %s) state: %s." \
        % (unit.name, unit.uid, unit.pilot_id, state)

    if state == rp.FAILED:
        print "stderr: %s" % unit.stderr
        sys.exit (1)

    if state in [rp.DONE, rp.FAILED, rp.CANCELED]:
        for cb in unit.callback_history:
            print cb

#------------------------------------------------------------------------------
#
def wait_queue_size_cb(umgr, wait_queue_size):
    """ 
    this callback is called when the size of the unit managers wait_queue
    changes.
    """
    print "[Callback]: UnitManager  '%s' wait_queue_size changed to %s." \
        % (umgr.uid, wait_queue_size)

    pilots = umgr.get_pilots ()
    for pilot in pilots:
        print "pilot %s: %s" % (pilot.uid, pilot.state)

    if wait_queue_size == 0:
        for pilot in pilots:
            if pilot.state in [rp.PENDING_LAUNCH,
                                rp.LAUNCHING     ,
                                rp.PENDING_ACTIVE]:
                print "cancel pilot %s" % pilot.uid
                umgr.remove_pilot (pilot.uid)
                pilot.cancel ()

#------------------------------------------------------------------------------
#
if __name__ == "__main__":

    if len(sys.argv) > 1:
        session_name = sys.argv[1]
    else:
        session_name = None

    dburl = "mongodb://ec2-54-221-194-147.compute-1.amazonaws.com:24242/"
    session = rp.Session(database_url=dburl, name=session_name, database_name='cdi-tests')
    sid = session.uid
    print "session id: %s" % sid

    cred = rp.Context('ssh')
    cred.user_id = "antontre"
    session.add_context(cred)

    try:
        pmgr = rp.PilotManager(session=session)
    
        pmgr.register_callback(pilot_state_cb)
        pdesc = rp.ComputePilotDescription()
        pdesc.resource = "xsede.stampede"
        pdesc.project  = "TG-MCB090174"
        pdesc.runtime  = 40 
        pdesc.queue    = "development"
        pdesc.cores    = 128
        pdesc.cleanup  = False
    
        pilot = pmgr.submit_pilots(pdesc)
    
        umgr = rp.UnitManager(
            session=session,
            scheduler=rp.SCHED_BACKFILLING)
    
        umgr.register_callback(unit_state_cb, rp.UNIT_STATE)

        umgr.register_callback(wait_queue_size_cb, rp.WAIT_QUEUE_SIZE)
        umgr.add_pilots(pilot)
    
        cuds = []
        for unit_count in range(0, 16):
            cud = rp.ComputeUnitDescription()
            cud.name          = "unit_%03d" % unit_count
            cud.executable    = "python"
            cud.pre_exec      = ["module load python"]
            cud.arguments     = ["hello_mpi.py"]
            cud.mpi           = True
            cud.cores         = 128
            cud.input_staging = ["hello_mpi.py"]
            cuds.append(cud)
    

        units = umgr.submit_units(cuds)
        umgr.wait_units()
    
        print 'units all done'
        print '----------------------------------------------------------------'
    
        for unit in units:
            unit.wait ()

        #-----------------------------------------------------------------------
        for unit in units:
            st_data = {}
            print unit.uid
            for st in unit.state_history:
                st_dict = st.as_dict()
                print st_dict
            print "\n"
                #st_data["{0}".format( st_dict["state"] )] = {}
                #st_data["{0}".format( st_dict["state"] )] = st_dict["timestamp"]
                
    
    except Exception as e:
        # Something unexpected happened in the pilot code above
        print "caught Exception: %s" % e
        raise

    except (KeyboardInterrupt, SystemExit) as e:
        print "need to exit now: %s" % e

    finally:
        print "closing session"
        session.close ()

