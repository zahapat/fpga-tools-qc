-- Protected type
--      - is an equivalent to a CLASS in VHDL

-- IMPURE/PURE function
--      - IMPURE = has side effects (can alter a variable...)
--                 - will alter the root object of the list 
--                   and will pass the root object (not in the parameter list, to avoid cluttering)

-- PRIVATE/PUBLIC region of the protected types to show or hide complexity of the implementation

-- ACCESS TYPES in VHDL:
--      1) create an incomplete type we want a pointer to point at (type item;)
--      2) create an access type (type ptr is access item;)
--      3) create a record type (type item is record...)


package fifo_pack_tb is
    type fifo_sim is protected

        -- Collection of subprograms PROTOTYPES:

        -- 1) ADD NEW element to the linked list
                    --( inputs to the procedure  );
        procedure push(constant data_new : in integer);
    
        -- 2.1) RETURN AND REMOVE THE OLDEST element from the linked list
        impure function pop return integer;

        -- 2.2) RETURN ONLY THE OLDEST element from the linked list without removing it (to check which element will be the next)
        impure function peek return integer;

        -- 3) EMPTY FIFO flag (0 elements in the linked list)
        impure function fifo_empty return boolean;

        -- -- 4) FULL FIFO flag (max elements in the linked list)
        -- impure function fifo_full return boolean;

    end protected fifo_sim;
end package fifo_pack_tb;


package body fifo_pack_tb is 

    type fifo_sim is protected body

        -- Linked list node
        type item;               -- incomplete data type (important) to prevent chicken egg problem
        type ptr is access item; -- "IS ACCESS" says that "ptr" will be a pointer to objects of type "item"
        type item is record      -- record is a container of multiple objects of various types in VHDL
            data          : integer;    -- default value is a large negative number
            ptr_next_item : ptr;        -- default value is a NULL pointer
        end record;


        -- Root of the linked list
        variable ptr_root : ptr;

        ---------------------------
        -- SUBPROGRAMS (METHODS) --
        ---------------------------
        -- 1) ADD NEW element to the linked list
        procedure push(constant data_new : in integer) is
            variable ptr_new_item : ptr;
            variable ptr_node     : ptr;
        begin

            ptr_new_item := new item;      -- ALLOCATE an item object with default values
            ptr_new_item.data := data_new; -- load new data
            
            if ptr_root = null then
                ptr_root := ptr_new_item;
            else
                -- copy root to node
                ptr_node := ptr_root;

                -- when some pointer points to some other node -> advance to that (next) node
                -- as the ptr_node.ptr_next_item = null again, then we reached the last item
                while ptr_node.ptr_next_item /= null loop
                    ptr_node := ptr_node.ptr_next_item;
                end loop;

                -- as the ptr_node.ptr_next_item = null again, then we reached the last item
                -- insert our last element there
                ptr_node.ptr_next_item := ptr_new_item;
            end if;
        end procedure;


        -- 2.1) RETURN AND REMOVE THE OLDEST element from the linked list
        impure function pop return integer is
            variable ptr_node : ptr;
            variable ret_val  : integer;
        begin

            ptr_node := ptr_root;               -- node will point to root
            ptr_root := ptr_node.ptr_next_item; -- detach the item from the linked list (that's why we have ptr_node := root; before otherwise we would lose it)

            ret_val := ptr_node.data;
            deallocate(ptr_node); -- DEALLOCATE/FREE the memory used by node

            return ret_val;
        end function;


        -- 2.2) RETURN ONLY THE OLDEST element from the linked list without removing it (to check which element will be the next)
        impure function peek return integer is
        begin
            return ptr_root.data;
        end function;


        -- 3) EMPTY FIFO flag (0 elements in the linked list)
        impure function fifo_empty return boolean is
        begin
            -- return true (=full) if null
            -- return false(= not full) if not full
            return ptr_root = null;
        end function;
    end protected body fifo_sim;

end package body fifo_pack_tb;